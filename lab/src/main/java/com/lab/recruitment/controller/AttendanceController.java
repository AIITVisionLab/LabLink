package com.lab.recruitment.controller;

import com.lab.recruitment.controller.support.ResultControllerSupport;
import com.lab.recruitment.dto.AttendanceManageTagDTO;
import com.lab.recruitment.dto.AttendanceSessionCreateDTO;
import com.lab.recruitment.dto.AttendanceSessionExpireDTO;
import com.lab.recruitment.dto.AttendanceSessionSignDTO;
import com.lab.recruitment.entity.User;
import com.lab.recruitment.service.AttendanceSessionService;
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
public class AttendanceController extends ResultControllerSupport {

    @Autowired
    private AttendanceSessionService attendanceSessionService;

    @PostMapping("/session/create")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPER_ADMIN', 'TEACHER')")
    public Result<Map<String, Object>> createSession(@Validated @RequestBody AttendanceSessionCreateDTO request) {
        return legacy(() -> attendanceSessionService.createSession(request.getLabId(), currentUser()));
    }

    @GetMapping("/session/active")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPER_ADMIN', 'TEACHER', 'STUDENT')")
    public Result<Map<String, Object>> getActiveSession(@RequestParam(required = false) Long labId) {
        return legacy(() -> {
            User currentUser = currentUser();
            boolean includeSensitiveData = currentUserAccessor.isAdmin(currentUser)
                    || currentUserAccessor.isTeacherIdentity(currentUser);
            return attendanceSessionService.getActiveSession(labId, currentUser, includeSensitiveData);
        });
    }

    @GetMapping("/session/records")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPER_ADMIN', 'TEACHER')")
    public Result<Map<String, Object>> getSessionRecords(@RequestParam Long sessionId) {
        return legacy(() -> attendanceSessionService.listSessionRecords(sessionId, currentUser()));
    }

    @PostMapping("/session/expire")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPER_ADMIN', 'TEACHER')")
    public Result<Map<String, Object>> expireSession(@Validated @RequestBody AttendanceSessionExpireDTO request) {
        return legacy(() -> attendanceSessionService.cancelSession(request.getSessionId(), currentUser()));
    }

    @PostMapping("/session/finalize")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPER_ADMIN', 'TEACHER')")
    public Result<Map<String, Object>> finalizeSession(@Validated @RequestBody AttendanceSessionExpireDTO request) {
        return legacy(() -> attendanceSessionService.finalizeSession(request.getSessionId(), currentUser()));
    }

    @PostMapping("/session/sign")
    @PreAuthorize("hasRole('STUDENT')")
    public Result<Map<String, Object>> sign(@Validated @RequestBody AttendanceSessionSignDTO request) {
        return legacy(() -> {
            User currentUser = currentUser();
            if (request.getSessionId() != null) {
                return attendanceSessionService.signBySession(currentUser.getId(), request.getSessionId(), currentUser);
            }
            return attendanceSessionService.signByCode(currentUser.getId(), request.getSignCode(), currentUser);
        });
    }

    @GetMapping("/manage/list")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPER_ADMIN', 'TEACHER')")
    public Result<Map<String, Object>> getManageList(@RequestParam(required = false) Long labId,
                                                     @RequestParam(required = false) String date) {
        return legacy(() -> attendanceSessionService.getAttendanceList(labId, date, currentUser()));
    }

    @PostMapping("/manage/tag")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPER_ADMIN', 'TEACHER')")
    public Result<Map<String, Object>> tagAttendance(@Validated @RequestBody AttendanceManageTagDTO request) {
        return legacy(() -> attendanceSessionService.tagAbsentMember(
                    request.getAttendanceId(),
                    request.getTagType(),
                    request.getReason(),
                    currentUser()));
    }

    @GetMapping("/manage/stat")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPER_ADMIN', 'TEACHER')")
    public Result<Map<String, Object>> getManageStat(@RequestParam(required = false) Long labId,
                                                     @RequestParam(required = false) String date) {
        return legacy(() -> attendanceSessionService.getAttendanceStat(labId, date, currentUser()));
    }

    @GetMapping("/manage/export")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPER_ADMIN', 'TEACHER')")
    public ResponseEntity<byte[]> export(@RequestParam(required = false) Long labId,
                                         @RequestParam(required = false) String startDate,
                                         @RequestParam(required = false) String endDate) {
        User currentUser = currentUser();
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
}
