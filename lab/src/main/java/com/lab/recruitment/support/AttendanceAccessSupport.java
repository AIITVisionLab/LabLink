package com.lab.recruitment.support;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.lab.recruitment.entity.AttendanceTask;
import com.lab.recruitment.entity.LabMember;
import com.lab.recruitment.entity.User;
import com.lab.recruitment.mapper.LabMemberMapper;
import com.lab.recruitment.service.UserAccessService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.Objects;

@Component
public class AttendanceAccessSupport {

    private static final String MEMBER_STATUS_ACTIVE = "active";
    private static final String MEMBER_ROLE_LAB_ADMIN = "lab_admin";

    @Autowired
    private CurrentUserAccessor currentUserAccessor;

    @Autowired
    private UserAccessService userAccessService;

    @Autowired
    private LabMemberMapper labMemberMapper;

    public Long resolveTaskScopeCollegeId(Long collegeId, User currentUser) {
        if (currentUserAccessor.isSuperAdmin(currentUser)) {
            return collegeId;
        }

        if (currentUserAccessor.isCollegeManager(currentUser)) {
            Long managedCollegeId = currentUserAccessor.resolveManagedCollegeId(currentUser);
            if (managedCollegeId == null) {
                throw new RuntimeException("Current account is not bound to a managed college");
            }
            if (collegeId != null && !Objects.equals(collegeId, managedCollegeId)) {
                throw new RuntimeException("You do not have access to another college");
            }
            return managedCollegeId;
        }

        if (resolveManagedLabId(currentUser) != null) {
            throw new RuntimeException("Only school directors or college managers can manage attendance tasks");
        }

        if (collegeId == null) {
            throw new RuntimeException("College id is required");
        }
        return collegeId;
    }

    public void assertTaskScope(AttendanceTask task, User currentUser) {
        if (task == null || task.getId() == null) {
            throw new RuntimeException("Attendance task does not exist");
        }
        if (currentUserAccessor.isSuperAdmin(currentUser)) {
            return;
        }
        Long scopedCollegeId = resolveTaskScopeCollegeId(task.getCollegeId(), currentUser);
        if (!Objects.equals(scopedCollegeId, task.getCollegeId())) {
            throw new RuntimeException("You do not have access to this attendance task");
        }
    }

    public Long resolveManagedLabId(User currentUser) {
        Long managedLabId = userAccessService.resolveManagedLabId(currentUser);
        if (managedLabId != null) {
            return managedLabId;
        }
        return currentUser == null ? null : currentUser.getLabId();
    }

    public Long resolveManageableLabId(User currentUser, Long requestedLabId) {
        if (currentUser == null || currentUser.getId() == null) {
            throw new RuntimeException("Current user is required");
        }
        return currentUserAccessor.resolveLabScope(currentUser, requestedLabId);
    }

    public Long resolveReadableLabId(User currentUser, Long requestedLabId) {
        if (currentUserAccessor.isStudentIdentity(currentUser)) {
            Long ownLabId = resolveCurrentUserLabId(currentUser);
            if (ownLabId == null) {
                throw new RuntimeException("You are not an active member of any lab");
            }
            if (requestedLabId != null && !Objects.equals(ownLabId, requestedLabId)) {
                throw new RuntimeException("No permission to access another lab");
            }
            return ownLabId;
        }
        return currentUserAccessor.resolveLabScope(currentUser, requestedLabId);
    }

    public Long resolveCurrentUserLabId(User currentUser) {
        if (currentUser == null || currentUser.getId() == null) {
            return null;
        }
        return resolveManagedLabId(currentUser);
    }

    public void ensureStudentMemberOfLab(User currentUser, Long labId) {
        Long ownLabId = resolveCurrentUserLabId(currentUser);
        if (ownLabId == null || !Objects.equals(ownLabId, labId)) {
            throw new RuntimeException("You do not belong to this lab");
        }
    }

    public void assertActiveLabMember(Long labId, Long userId) {
        if (labId == null || userId == null) {
            throw new RuntimeException("Student record does not belong to this lab");
        }

        QueryWrapper<LabMember> memberQuery = new QueryWrapper<>();
        memberQuery.eq("lab_id", labId)
                .eq("user_id", userId)
                .eq("deleted", 0)
                .eq("status", MEMBER_STATUS_ACTIVE)
                .and(wrapper -> wrapper.isNull("member_role").or().ne("member_role", MEMBER_ROLE_LAB_ADMIN))
                .last("LIMIT 1");
        if (labMemberMapper.selectOne(memberQuery) == null) {
            throw new RuntimeException("Student record does not belong to this lab");
        }
    }
}
