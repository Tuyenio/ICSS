package controller;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Chống brute-force đăng nhập (in-memory).
 *
 * Đếm số lần đăng nhập sai theo CẢ email lẫn IP:
 *  - Sai >= MAX_FAILS lần trong WINDOW → khóa LOCK_MS.
 *  - Khóa theo email: chặn dò mật khẩu 1 tài khoản dù đổi IP.
 *  - Khóa theo IP: chặn 1 IP spray nhiều tài khoản.
 *  - Đăng nhập thành công → reset bộ đếm.
 *
 * Lưu ý: trạng thái nằm trong RAM (mất khi restart). Đủ cho app HRM quy mô
 * nhỏ; nếu chạy nhiều node cần chuyển sang store dùng chung (DB/Redis).
 */
public final class LoginThrottle {

    private LoginThrottle() {}

    private static final int  MAX_FAILS = 5;
    private static final long WINDOW_MS = 15 * 60 * 1000L; // cửa sổ đếm: 15 phút
    private static final long LOCK_MS   = 15 * 60 * 1000L; // thời gian khóa: 15 phút
    private static final int  MAX_ENTRIES = 10000;         // chặn phình bộ nhớ

    private static final class Entry {
        int fails;
        long windowStart;
        long lockUntil;
    }

    private static final Map<String, Entry> MAP = new ConcurrentHashMap<>();

    private static String norm(String s) {
        return (s == null) ? "" : s.trim().toLowerCase();
    }

    /** Số giây còn bị khóa (xét cả email và IP); 0 nếu không bị khóa. */
    public static long lockedSeconds(String email, String ip) {
        return Math.max(lockedSecondsKey("e:" + norm(email)),
                        lockedSecondsKey("i:" + norm(ip)));
    }

    /** Ghi nhận 1 lần đăng nhập sai cho cả email và IP. */
    public static void recordFailure(String email, String ip) {
        recordFailureKey("e:" + norm(email));
        recordFailureKey("i:" + norm(ip));
    }

    /** Xóa bộ đếm khi đăng nhập thành công. */
    public static void reset(String email, String ip) {
        MAP.remove("e:" + norm(email));
        MAP.remove("i:" + norm(ip));
    }

    private static long lockedSecondsKey(String key) {
        Entry e = MAP.get(key);
        if (e == null) {
            return 0;
        }
        long now = System.currentTimeMillis();
        if (e.lockUntil > now) {
            return (e.lockUntil - now) / 1000 + 1;
        }
        return 0;
    }

    private static synchronized void recordFailureKey(String key) {
        long now = System.currentTimeMillis();
        if (MAP.size() > MAX_ENTRIES) {
            MAP.entrySet().removeIf(en -> en.getValue().lockUntil < now
                    && (now - en.getValue().windowStart) > WINDOW_MS);
        }
        Entry e = MAP.computeIfAbsent(key, k -> {
            Entry ne = new Entry();
            ne.windowStart = now;
            return ne;
        });
        if (now - e.windowStart > WINDOW_MS) {
            e.fails = 0;
            e.windowStart = now;
        }
        e.fails++;
        if (e.fails >= MAX_FAILS) {
            e.lockUntil = now + LOCK_MS;
            e.fails = 0;
            e.windowStart = now;
        }
    }
}
