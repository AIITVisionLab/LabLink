package com.lab.recruitment.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.lab.recruitment.controller.support.ResultControllerSupport;
import com.lab.recruitment.dto.AttendanceLeaveApplyDTO;
import com.lab.recruitment.dto.AttendanceLeaveReviewDTO;
import com.lab.recruitment.dto.AttendanceMakeupRequestDTO;
import com.lab.recruitment.dto.AttendanceDutyUpsertDTO;
import com.lab.recruitment.dto.AttendanceRecordReviewDTO;
import com.lab.recruitment.dto.AttendanceScheduleDTO;
import com.lab.recruitment.dto.AttendanceSignInDTO;
import com.lab.recruitment.dto.AttendanceTaskUpsertDTO;
import com.lab.recruitment.entity.AttendanceSchedule;
import com.lab.recruitment.service.AttendanceWorkflowService;
import com.lab.recruitment.utils.Result;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/attendance-workflow")
public class AttendanceWorkflowController extends ResultControllerSupport {

    @Autowired
    private AttendanceWorkflowService attendanceWorkflowService;

    @GetMapping("/tasks")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPER_ADMIN')")
    public Result<Page<Map<String, Object>>> getTaskPage(@RequestParam(defaultValue = "1") Integer pageNum,
                                                         @RequestParam(defaultValue = "10") Integer pageSize,
                                                         @RequestParam(required = false) Long collegeId,
                                                         @RequestParam(required = false) String keyword) {
        return legacy(() -> attendanceWorkflowService.getTaskPage(pageNum, pageSize, collegeId, keyword, currentUser()));
    }

    @PostMapping("/tasks")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPER_ADMIN')")
    public Result<Map<String, Object>> saveTask(@Validated @RequestBody AttendanceTaskUpsertDTO taskDTO) {
        return legacy(() -> attendanceWorkflowService.saveTask(taskDTO, currentUser()));
    }

    @PostMapping("/tasks/{taskId}/publish")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPER_ADMIN')")
    public Result<Boolean> publishTask(@PathVariable Long taskId) {
        return legacy(() -> attendanceWorkflowService.publishTask(taskId, currentUser()));
    }

    @GetMapping("/tasks/{taskId}/schedules")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPER_ADMIN')")
    public Result<List<AttendanceSchedule>> getTaskSchedules(@PathVariable Long taskId) {
        return legacy(() -> attendanceWorkflowService.getTaskSchedules(taskId, currentUser()));
    }

    @PostMapping("/tasks/{taskId}/schedules")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPER_ADMIN')")
    public Result<List<AttendanceSchedule>> saveTaskSchedules(@PathVariable Long taskId,
                                                              @RequestBody List<AttendanceScheduleDTO> schedules) {
        return legacy(() -> attendanceWorkflowService.saveTaskSchedules(taskId, schedules, currentUser()));
    }

    @GetMapping("/summary")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPER_ADMIN')")
    public Result<Map<String, Object>> getSummary(@RequestParam(required = false) Long taskId,
                                                  @RequestParam(required = false) Long labId) {
        return legacy(() -> attendanceWorkflowService.getAttendanceSummary(taskId, labId, currentUser()));
    }

    @GetMapping("/lab/session/current")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPER_ADMIN', 'TEACHER')")
    public Result<Map<String, Object>> getCurrentLabSession() {
        return legacy(() -> attendanceWorkflowService.getCurrentLabSession(currentUser()));
    }

    @GetMapping("/lab/session/current/records")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPER_ADMIN', 'TEACHER')")
    public Result<List<Map<String, Object>>> getCurrentLabSessionRecords() {
        return legacy(() -> attendanceWorkflowService.getCurrentLabSessionRecords(currentUser()));
    }

    @GetMapping("/lab/leaves")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPER_ADMIN', 'TEACHER')")
    public Result<Page<Map<String, Object>>> getPendingLabLeaves(@RequestParam(defaultValue = "1") Integer pageNum,
                                                                 @RequestParam(defaultValue = "10") Integer pageSize,
                                                                 @RequestParam(required = false) Long labId,
                                                                 @RequestParam(required = false) String leaveStatus,
                                                                 @RequestParam(required = false) String keyword) {
        return legacy(() -> attendanceWorkflowService.getPendingLeavePage(
                pageNum, pageSize, labId, leaveStatus, keyword, currentUser()));
    }

    @PostMapping("/lab/records/review")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPER_ADMIN')")
    public Result<Boolean> reviewLabAttendanceRecord(@Validated @RequestBody AttendanceRecordReviewDTO reviewDTO) {
        return legacy(() -> attendanceWorkflowService.reviewLabAttendanceRecord(reviewDTO, currentUser()));
    }

    @PostMapping("/lab/session/current/photo")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPER_ADMIN')")
    public Result<Map<String, Object>> uploadCurrentSessionPhoto(@RequestParam("file") MultipartFile file,
                                                                 @RequestParam(value = "remark", required = false) String remark) {
        return legacy(() -> attendanceWorkflowService.uploadCurrentSessionPhoto(file, remark, currentUser()));
    }

    @PostMapping("/duty/sessions/{sessionId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPER_ADMIN')")
    public Result<Map<String, Object>> setSessionDuty(@PathVariable Long sessionId,
                                                      @Validated @RequestBody AttendanceDutyUpsertDTO dutyDTO) {
        return legacy(() -> attendanceWorkflowService.setSessionDuty(sessionId, dutyDTO, currentUser()));
    }

    @GetMapping("/student/session/current")
    @PreAuthorize("hasRole('STUDENT')")
    public Result<Map<String, Object>> getCurrentStudentSession() {
        return legacy(() -> attendanceWorkflowService.getCurrentStudentSession(currentUser()));
    }

    @PostMapping("/student/session/sign-in")
    @PreAuthorize("hasRole('STUDENT')")
    public Result<Boolean> studentSignIn(@Validated @RequestBody AttendanceSignInDTO signInDTO) {
        return legacy(() -> attendanceWorkflowService.studentSignIn(signInDTO, currentUser()));
    }

    @PostMapping("/student/session/leave")
    @PreAuthorize("hasRole('STUDENT')")
    public Result<Map<String, Object>> studentApplyLeave(@Validated @RequestBody AttendanceLeaveApplyDTO leaveDTO) {
        return legacy(() -> attendanceWorkflowService.studentApplyLeave(leaveDTO, currentUser()));
    }

    @PostMapping("/student/session/makeup")
    @PreAuthorize("hasRole('STUDENT')")
    public Result<Boolean> studentRequestMakeup(@Validated @RequestBody AttendanceMakeupRequestDTO requestDTO) {
        return legacy(() -> attendanceWorkflowService.studentRequestMakeup(requestDTO, currentUser()));
    }

    @GetMapping("/student/history")
    @PreAuthorize("hasRole('STUDENT')")
    public Result<Page<Map<String, Object>>> getStudentHistory(@RequestParam(defaultValue = "1") Integer pageNum,
                                                               @RequestParam(defaultValue = "10") Integer pageSize) {
        return legacy(() -> attendanceWorkflowService.getStudentHistory(pageNum, pageSize, currentUser()));
    }

    @PostMapping("/lab/leaves/{leaveId}/approve")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPER_ADMIN')")
    public Result<Map<String, Object>> approveLeave(@PathVariable Long leaveId,
                                                    @Validated @RequestBody AttendanceLeaveReviewDTO reviewDTO) {
        return legacy(() -> attendanceWorkflowService.approveLeave(leaveId, reviewDTO, currentUser()));
    }

    @PostMapping("/lab/leaves/{leaveId}/reject")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPER_ADMIN')")
    public Result<Map<String, Object>> rejectLeave(@PathVariable Long leaveId,
                                                   @Validated @RequestBody AttendanceLeaveReviewDTO reviewDTO) {
        return legacy(() -> attendanceWorkflowService.rejectLeave(leaveId, reviewDTO, currentUser()));
    }
}
