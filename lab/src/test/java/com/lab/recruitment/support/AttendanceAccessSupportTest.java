package com.lab.recruitment.support;

import com.lab.recruitment.entity.AttendanceTask;
import com.lab.recruitment.entity.LabMember;
import com.lab.recruitment.entity.User;
import com.lab.recruitment.mapper.LabMemberMapper;
import com.lab.recruitment.service.UserAccessService;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class AttendanceAccessSupportTest {

    @Mock
    private CurrentUserAccessor currentUserAccessor;

    @Mock
    private UserAccessService userAccessService;

    @Mock
    private LabMemberMapper labMemberMapper;

    @InjectMocks
    private AttendanceAccessSupport attendanceAccessSupport;

    @Test
    void resolveReadableLabIdUsesStudentOwnLab() {
        User currentUser = buildUser(7L, 12L);
        when(currentUserAccessor.isStudentIdentity(currentUser)).thenReturn(true);
        when(userAccessService.resolveManagedLabId(currentUser)).thenReturn(12L);

        Long scopedLabId = attendanceAccessSupport.resolveReadableLabId(currentUser, null);

        assertEquals(12L, scopedLabId);
        verify(currentUserAccessor, never()).resolveLabScope(any(), any());
    }

    @Test
    void resolveReadableLabIdRejectsAnotherStudentLab() {
        User currentUser = buildUser(7L, 12L);
        when(currentUserAccessor.isStudentIdentity(currentUser)).thenReturn(true);
        when(userAccessService.resolveManagedLabId(currentUser)).thenReturn(12L);

        RuntimeException exception = assertThrows(RuntimeException.class,
                () -> attendanceAccessSupport.resolveReadableLabId(currentUser, 99L));

        assertEquals("No permission to access another lab", exception.getMessage());
    }

    @Test
    void resolveTaskScopeCollegeIdUsesManagedCollegeForCollegeManager() {
        User currentUser = buildUser(7L, null);
        when(currentUserAccessor.isSuperAdmin(currentUser)).thenReturn(false);
        when(currentUserAccessor.isCollegeManager(currentUser)).thenReturn(true);
        when(currentUserAccessor.resolveManagedCollegeId(currentUser)).thenReturn(5L);

        Long scopedCollegeId = attendanceAccessSupport.resolveTaskScopeCollegeId(null, currentUser);

        assertEquals(5L, scopedCollegeId);
    }

    @Test
    void assertTaskScopeRejectsMismatchedCollege() {
        User currentUser = buildUser(7L, null);
        AttendanceTask task = new AttendanceTask();
        task.setId(3L);
        task.setCollegeId(8L);

        when(currentUserAccessor.isSuperAdmin(currentUser)).thenReturn(false);
        when(currentUserAccessor.isCollegeManager(currentUser)).thenReturn(true);
        when(currentUserAccessor.resolveManagedCollegeId(currentUser)).thenReturn(5L);

        RuntimeException exception = assertThrows(RuntimeException.class,
                () -> attendanceAccessSupport.assertTaskScope(task, currentUser));

        assertEquals("You do not have access to another college", exception.getMessage());
    }

    @Test
    void assertActiveLabMemberRejectsMissingMember() {
        when(labMemberMapper.selectOne(any())).thenReturn(null);

        RuntimeException exception = assertThrows(RuntimeException.class,
                () -> attendanceAccessSupport.assertActiveLabMember(3L, 8L));

        assertEquals("Student record does not belong to this lab", exception.getMessage());
    }

    @Test
    void assertActiveLabMemberAcceptsActiveMember() {
        when(labMemberMapper.selectOne(any())).thenReturn(new LabMember());

        attendanceAccessSupport.assertActiveLabMember(3L, 8L);

        verify(labMemberMapper).selectOne(any());
    }

    private User buildUser(Long userId, Long labId) {
        User user = new User();
        user.setId(userId);
        user.setLabId(labId);
        return user;
    }
}
