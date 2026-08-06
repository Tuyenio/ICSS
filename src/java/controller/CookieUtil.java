package controller;

import javax.crypto.Cipher;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;

/**
 * Mã hóa/giải mã giá trị cookie an toàn.
 *
 * Thay đổi bảo mật (2026-06-09):
 *  - Khóa KHÔNG còn hardcode trong source; lấy từ biến môi trường
 *    ICSS_COOKIE_SECRET (đặt trên server, không commit). Key 256-bit
 *    được suy ra bằng SHA-256 của secret.
 *  - Dùng AES/GCM (authenticated encryption) thay cho AES/ECB. GCM có
 *    integrity tag nên cookie bị giả mạo / sửa đổi sẽ giải mã thất bại
 *    → chặn việc tự chế cookie để leo thang quyền (vaiTro=admin).
 *  - IV ngẫu nhiên 12 byte, prepend vào ciphertext.
 *
 * Fail-closed: nếu thiếu ICSS_COOKIE_SECRET, encrypt/decrypt trả về null
 * (cookie "ghi nhớ đăng nhập" không hoạt động, nhưng đăng nhập bằng phiên
 * vẫn bình thường). Cookie theo cơ chế cũ (ECB) sẽ không giải mã được nữa
 * → người dùng cần đăng nhập lại (mong muốn, vì khóa cũ đã lộ).
 */
public class CookieUtil {

    private static final String TRANSFORMATION = "AES/GCM/NoPadding";
    private static final int IV_LENGTH = 12;        // 96-bit IV cho GCM
    private static final int TAG_LENGTH_BITS = 128; // tag 128-bit
    private static final SecureRandom RANDOM = new SecureRandom();

    /** Suy ra khóa AES-256 từ biến môi trường; null nếu chưa cấu hình. */
    private static SecretKeySpec keySpec() {
        String secret = System.getenv("ICSS_COOKIE_SECRET");
        if (secret == null || secret.trim().length() < 16) {
            System.err.println("[CookieUtil] Thiếu/yếu ICSS_COOKIE_SECRET — cookie bảo mật bị vô hiệu hóa.");
            return null;
        }
        try {
            byte[] hash = MessageDigest.getInstance("SHA-256")
                    .digest(secret.getBytes(StandardCharsets.UTF_8));
            return new SecretKeySpec(hash, "AES");
        } catch (Exception e) {
            System.err.println("[CookieUtil] Lỗi suy ra khóa: " + e.getMessage());
            return null;
        }
    }

    /** Mã hóa giá trị để lưu vào cookie. Trả về null nếu không thể mã hóa. */
    public static String encrypt(String value) {
        try {
            SecretKeySpec key = keySpec();
            if (key == null || value == null) {
                return null;
            }
            byte[] iv = new byte[IV_LENGTH];
            RANDOM.nextBytes(iv);

            Cipher cipher = Cipher.getInstance(TRANSFORMATION);
            cipher.init(Cipher.ENCRYPT_MODE, key, new GCMParameterSpec(TAG_LENGTH_BITS, iv));
            byte[] cipherText = cipher.doFinal(value.getBytes(StandardCharsets.UTF_8));

            // [IV || ciphertext+tag]
            byte[] out = new byte[iv.length + cipherText.length];
            System.arraycopy(iv, 0, out, 0, iv.length);
            System.arraycopy(cipherText, 0, out, iv.length, cipherText.length);

            return Base64.getUrlEncoder().withoutPadding().encodeToString(out);
        } catch (Exception e) {
            System.err.println("Encryption error: " + e.getMessage());
            return null;
        }
    }

    /** Giải mã giá trị từ cookie. Trả về null nếu cookie sai/giả mạo/khóa thiếu. */
    public static String decrypt(String encryptedValue) {
        try {
            SecretKeySpec key = keySpec();
            if (key == null || encryptedValue == null) {
                return null;
            }
            byte[] all = Base64.getUrlDecoder().decode(encryptedValue);
            if (all.length <= IV_LENGTH) {
                return null;
            }
            byte[] iv = new byte[IV_LENGTH];
            byte[] cipherText = new byte[all.length - IV_LENGTH];
            System.arraycopy(all, 0, iv, 0, IV_LENGTH);
            System.arraycopy(all, IV_LENGTH, cipherText, 0, cipherText.length);

            Cipher cipher = Cipher.getInstance(TRANSFORMATION);
            cipher.init(Cipher.DECRYPT_MODE, key, new GCMParameterSpec(TAG_LENGTH_BITS, iv));
            byte[] decrypted = cipher.doFinal(cipherText); // ném exception nếu tag sai (giả mạo)

            return new String(decrypted, StandardCharsets.UTF_8);
        } catch (Exception e) {
            // Cookie cũ (ECB) / bị sửa đổi / khóa sai → coi như không hợp lệ
            System.err.println("Decryption error: " + e.getMessage());
            return null;
        }
    }
}
