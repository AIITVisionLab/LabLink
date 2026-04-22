package com.lab.recruitment.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.cache.Cache;
import org.springframework.cache.CacheManager;
import org.springframework.cache.interceptor.CacheErrorHandler;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.cache.concurrent.ConcurrentMapCacheManager;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.cache.RedisCacheConfiguration;
import org.springframework.data.redis.cache.RedisCacheManager;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.serializer.GenericJackson2JsonRedisSerializer;
import org.springframework.data.redis.serializer.RedisSerializationContext;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.time.Duration;
import java.util.HashMap;
import java.util.Map;

@Configuration
@EnableCaching
@EnableConfigurationProperties(PlatformCacheProperties.class)
public class PlatformCacheConfig {

    private static final Logger log = LoggerFactory.getLogger(PlatformCacheConfig.class);

    @Bean
    @ConditionalOnProperty(prefix = "lablink.cache.redis", name = "enabled", havingValue = "true")
    public CacheManager redisCacheManager(RedisConnectionFactory redisConnectionFactory, ObjectMapper objectMapper) {
        GenericJackson2JsonRedisSerializer serializer = new GenericJackson2JsonRedisSerializer(objectMapper);
        RedisCacheConfiguration baseConfig = RedisCacheConfiguration.defaultCacheConfig()
                .serializeValuesWith(RedisSerializationContext.SerializationPair.fromSerializer(serializer))
                .disableCachingNullValues();

        Map<String, RedisCacheConfiguration> cacheConfigurations = new HashMap<>();
        cacheConfigurations.put(PlatformCacheNames.LAB_DETAIL, baseConfig.entryTtl(Duration.ofMinutes(30)));
        cacheConfigurations.put(PlatformCacheNames.AUTH_MENU, baseConfig.entryTtl(Duration.ofHours(1)));
        cacheConfigurations.put(PlatformCacheNames.AUTH_PERMISSION, baseConfig.entryTtl(Duration.ofHours(1)));
        cacheConfigurations.put(PlatformCacheNames.STAT_DASHBOARD, baseConfig.entryTtl(Duration.ofMinutes(10)));
        cacheConfigurations.put(PlatformCacheNames.STAT_LABS, baseConfig.entryTtl(Duration.ofMinutes(10)));
        cacheConfigurations.put(PlatformCacheNames.STAT_MEMBERS, baseConfig.entryTtl(Duration.ofMinutes(10)));
        cacheConfigurations.put(PlatformCacheNames.STAT_ATTENDANCE, baseConfig.entryTtl(Duration.ofMinutes(10)));
        cacheConfigurations.put(PlatformCacheNames.STAT_DEVICES, baseConfig.entryTtl(Duration.ofMinutes(10)));
        cacheConfigurations.put(PlatformCacheNames.STAT_PROFILES, baseConfig.entryTtl(Duration.ofMinutes(10)));
        cacheConfigurations.put(PlatformCacheNames.SEARCH_GLOBAL, baseConfig.entryTtl(Duration.ofMinutes(5)));

        return RedisCacheManager.builder(redisConnectionFactory)
                .cacheDefaults(baseConfig.entryTtl(Duration.ofMinutes(30)))
                .withInitialCacheConfigurations(cacheConfigurations)
                .transactionAware()
                .build();
    }

    @Bean
    @ConditionalOnMissingBean(CacheManager.class)
    public CacheManager localCacheManager() {
        return new ConcurrentMapCacheManager(
                PlatformCacheNames.LAB_DETAIL,
                PlatformCacheNames.AUTH_MENU,
                PlatformCacheNames.AUTH_PERMISSION,
                PlatformCacheNames.STAT_DASHBOARD,
                PlatformCacheNames.STAT_LABS,
                PlatformCacheNames.STAT_MEMBERS,
                PlatformCacheNames.STAT_ATTENDANCE,
                PlatformCacheNames.STAT_DEVICES,
                PlatformCacheNames.STAT_PROFILES,
                PlatformCacheNames.SEARCH_GLOBAL
        );
    }

    @Bean
    public CacheErrorHandler cacheErrorHandler() {
        return new CacheErrorHandler() {
            @Override
            public void handleCacheGetError(RuntimeException exception, Cache cache, Object key) {
                log.warn("Cache get failed for cache={} key={}, falling back to direct execution", cacheName(cache), key, exception);
            }

            @Override
            public void handleCachePutError(RuntimeException exception, Cache cache, Object key, Object value) {
                log.warn("Cache put failed for cache={} key={}, skipping cache write", cacheName(cache), key, exception);
            }

            @Override
            public void handleCacheEvictError(RuntimeException exception, Cache cache, Object key) {
                log.warn("Cache evict failed for cache={} key={}", cacheName(cache), key, exception);
            }

            @Override
            public void handleCacheClearError(RuntimeException exception, Cache cache) {
                log.warn("Cache clear failed for cache={}", cacheName(cache), exception);
            }

            private String cacheName(Cache cache) {
                return cache == null ? "unknown" : cache.getName();
            }
        };
    }
}
