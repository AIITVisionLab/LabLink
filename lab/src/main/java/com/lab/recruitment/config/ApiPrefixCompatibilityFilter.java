package com.lab.recruitment.config;

import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletRequestWrapper;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@Component
@Order(Ordered.HIGHEST_PRECEDENCE)
public class ApiPrefixCompatibilityFilter extends OncePerRequestFilter {

    private static final String API_PREFIX = "/api";

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        String requestUri = request.getRequestURI();
        String contextPath = request.getContextPath();
        String path = requestUri.startsWith(contextPath)
                ? requestUri.substring(contextPath.length())
                : requestUri;
        return !path.equals(API_PREFIX) && !path.startsWith(API_PREFIX + "/");
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {
        String contextPath = request.getContextPath();
        String requestUri = request.getRequestURI();
        String path = requestUri.startsWith(contextPath)
                ? requestUri.substring(contextPath.length())
                : requestUri;
        String strippedPath = stripApiPrefix(path);

        HttpServletRequestWrapper wrappedRequest = new HttpServletRequestWrapper(request) {
            @Override
            public String getRequestURI() {
                return contextPath + strippedPath;
            }

            @Override
            public StringBuffer getRequestURL() {
                return new StringBuffer(buildRequestUrl(request, contextPath + strippedPath));
            }

            @Override
            public String getServletPath() {
                return strippedPath;
            }

            @Override
            public String getPathInfo() {
                return null;
            }
        };

        filterChain.doFilter(wrappedRequest, response);
    }

    private String stripApiPrefix(String path) {
        if (path == null || path.isBlank() || API_PREFIX.equals(path)) {
            return "/";
        }
        return path.startsWith(API_PREFIX + "/") ? path.substring(API_PREFIX.length()) : path;
    }

    private String buildRequestUrl(HttpServletRequest request, String requestUri) {
        StringBuffer originalUrl = request.getRequestURL();
        String originalUri = request.getRequestURI();
        String baseUrl = originalUrl.substring(0, originalUrl.length() - originalUri.length());
        return baseUrl + requestUri;
    }
}
