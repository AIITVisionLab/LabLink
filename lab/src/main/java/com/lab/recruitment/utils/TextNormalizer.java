package com.lab.recruitment.utils;

import org.springframework.util.StringUtils;

public final class TextNormalizer {

    private TextNormalizer() {
    }

    public static String trimToNull(String value) {
        if (!StringUtils.hasText(value)) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }
}
