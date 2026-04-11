package com.lab.recruitment.controller;

import com.lab.recruitment.dto.AttendanceManageTagDTO;
import com.lab.recruitment.dto.AttendanceSessionCreateDTO;
import com.lab.recruitment.dto.AttendanceSessionExpireDTO;
import com.lab.recruitment.dto.AttendanceSessionSignDTO;
import com.lab.recruitment.entity.User;
import com.lab.recruitment.service.AttendanceSessionService;
import com.lab.recruitment.support.CurrentUserAccessor;
import com.lab.recruitment.utils.Result;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ContentDisposition;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.util.Map;

@RestController
@RequestMapping("/attendance")
public class AttendanceController {

    @Autowired
    private AttendanceSessionService attendanceSessionService;

    @Autowired
    private CurrentUserAccessor currentUserAccessor;

    @PostMapping("/session/create")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPER_ADMIN', 'TEACHER')")
    public Result<Map<String, Object>> createSession(@Validated @RequestBody AttendanceSessionCreateDTO request) {
        try {
            return Result.success(attendanceSessionService.createSession(request.getLabId(), getCurrentUser()));
        } catch (Exception exception) {
            return Result.error(exception.getMessage());
        }
    }

    @GetMapping("/session/active")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPER_ADMIN', 'TEACHER', 'STUDENT')")
    public Result<Map<String, Object>> getActiveSession(@RequestParam(required = false) Long labId) {
        try {
            User currentUser = getCurrentUser();
            boolean includeSensitiveData = currentUserAccessor.isAdmin(currentUser)
                    || currentUserAccessor.isTeacherIdentity(currentUser);
            return Result.success(attendanceSessionService.getActiveSession(labId, currentUser, includeSensitiveData));
        } catch (Exception exception) {
            return Result.error(exception.getMessage());
        }
    }

    @GetMapping("/session/records")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPER_ADMIN', 'TEACHER')")
    public Result<Map<String, Object>> getSessionRecords(@RequestParam Long sessionId) {
        try {
            return Result.success(attendanceSessionService.listSessionRecords(sessionId, getCurrentUser()));
        } catch (Exception exception) {
            return Result.error(exception.getMessage());
        }
    }

    @PostMapping("/session/expire")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPER_ADMIN', 'TEACHER')")
    public Result<Map<String, Object>> expireSession(@Validated @RequestBody AttendanceSessionExpireDTO request) {
        try {
            return Result.success(attendanceSessionService.cancelSession(request.getSessionId(), getCurrentUser()));
        } catch (Exception exception) {
            return Result.error(exception.getMessage());
        }
    }

    @PostMapping("/session/finalize")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPER_ADMIN', 'TEACHER')")
    public Result<Map<String, Object>> finalizeSession(@Validated @RequestBody AttendanceSessionExpireDTO request) {
        try {
            return Result.success(attendanceSessionService.finalizeSession(request.getSessionId(), getCurrentUser()));
        } catch (Exception exception) {
            return Result.error(exception.getMessage());
        }
    }

    @PostMapping("/session/sign")
    @PreAuthorize("hasRole('STUDENT')")
    public Result<Map<String, Object>> sign(@Validated @RequestBody AttendanceSessionSignDTO request) {
        try {
            User currentUser = getCurrentUser();
            if (request.getSessionId() != null) {
                return Result.success(attendanceSessionService.signBySession(currentUser.getId(), request.getSessionId(), currentUser));
            }
            return Result.success(attendanceSessionService.signByCode(currentUser.getId(), request.getSignCode(), currentUser));
        } catch (Exception exception) {
            return Result.error(exception.getMessage());
        }
    }

    @GetMapping("/manage/list")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPER_ADMIN', 'TEACHER')")
    public Result<Map<String, Object>> getManageList(@RequestParam(required = false) Long labId,
                                                     @RequestParam(required = false) String date) {
        try {
            return Result.success(attendanceSessionService.getAttendanceList(labId, date, getCurrentUser()));
        } catch (Exception exception) {
            return Result.error(exception.getMessage());
        }
    }

    @PostMapping("/manage/tag")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPER_ADMIN', 'TEACHER')")
    public Result<Map<String, Object>> tagAttendance(@Validated @RequestBody AttendanceManageTagDTO request) {
        try {
            return Result.success(attendanceSessionService.tagAbsentMember(
                    request.getAttendanceId(),
                    request.getTagType(),
                    request.getReason(),
                    getCurrentUser()));
        } catch (Exception exception) {
            return Result.error(exception.getMessage());
        }
    }

    @GetMapping("/manage/stat")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPER_ADMIN', 'TEACHER')")
    public Result<Map<String, Object>> getManageStat(@RequestParam(required = false) Long labId,
                                                     @RequestParam(required = false) String date) {
        try {
            return Result.success(attendanceSessionService.getAttendanceStat(labId, date, getCurrentUser()));
        } catch (Exception exception) {
            return Result.error(exception.getMessage());
        }
    }

    @GetMapping("/manage/export")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPER_ADMIN', 'TEACHER')")
    public ResponseEntity<byte[]> export(@RequestParam(required = false) Long labId,
                                         @RequestParam(required = false) String startDate,
                                         @RequestParam(required = false) String endDate) {
        User currentUser = getCurrentUser();
        byte[] bytes = attendanceSessionService.exportAttendanceExcel(labId, startDate, endDate, currentUser);
        String datePart = LocalDate.now().toString();
        String fileName = "attendance-" + datePart + ".xlsx";
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.parseMediaType(
                "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"));
        headers.setContentDisposition(ContentDisposition.attachment()
                .filename(fileName, StandardCharsets.UTF_8)
                .build());
        return ResponseEntity.ok()
                .headers(headers)
                .body(bytes);
    }

    private User getCurrentUser() {
        User user = currentUserAccessor.getCurrentUser();
        user.setPassword(null);
        return user;
    }
}
