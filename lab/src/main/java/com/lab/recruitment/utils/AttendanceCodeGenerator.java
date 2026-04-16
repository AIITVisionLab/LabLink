package com.lab.recruitment.utils;

import java.util.concurrent.ThreadLocalRandom;

public final class AttendanceCodeGenerator {

    private AttendanceCodeGenerator() {
    }

    public static String generateSignCode(int length) {
        int safeLength = Math.max(length, 1);
        StringBuilder builder = new StringBuilder(safeLength);
        ThreadLocalRandom random = ThreadLocalRandom.current();
        for (int index = 0; index < safeLength; index++) {
            builder.append(random.nextInt(10));
        }
        return builder.toString();
    }
}
