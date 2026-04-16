package com.lab.recruitment.controller.support;

import com.lab.recruitment.entity.User;
import com.lab.recruitment.support.CurrentUserAccessor;
import com.lab.recruitment.utils.Result;
import org.springframework.beans.factory.annotation.Autowired;

public abstract class ResultControllerSupport {

    @Autowired
    protected CurrentUserAccessor currentUserAccessor;

    protected User currentUser() {
        return currentUserAccessor.getCurrentUser();
    }

    protected <T> Result<T> legacy(ResultSupplier<T> supplier) {
        try {
            return Result.success(supplier.get());
        } catch (Exception exception) {
            return Result.error(exception.getMessage());
        }
    }

    protected <T> Result<T> api(ResultSupplier<T> supplier) {
        try {
            return Result.apiSuccess(supplier.get());
        } catch (Exception exception) {
            return Result.error(exception.getMessage());
        }
    }

    @FunctionalInterface
    protected interface ResultSupplier<T> {
        T get() throws Exception;
    }
}
