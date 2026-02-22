package com.nodove.community.nodove.configuration.security.constructor;

import com.nodove.community.nodove.domain.users.User;
import com.nodove.community.nodove.domain.users.UserBlock;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.Collections;

@Getter
@Slf4j
@RequiredArgsConstructor
public class PrincipalDetails implements UserDetails {

    private final User user;
    private final UserBlock userBlock;

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return Collections.singletonList(new SimpleGrantedAuthority(this.user.getUserRole().name()));
    }

    @Override
    public String getPassword() {
        return this.user.getPassword();
    }

    @Override
    public String getUsername() {
        return this.user.getUsername();
    }

    public String getUserId() {
        return this.user.getUserId();
    }

    public String getEmail() {
        return this.user.getEmail();
    }

    public String getNickname() {
        return this.user.getUserNick();
    }

    @Override
    public boolean isAccountNonExpired() {
        if (userBlock == null) {
            return true;
        }
        return !userBlock.checkIsBlocked();
    }

    @Override
    public boolean isAccountNonLocked() {
        if (userBlock == null) {
            return true;
        }
        return !userBlock.checkIsBlocked();
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    public boolean isEnabled() {
        if (user.getIsActive())
            if (userBlock == null) {
                return true;
            }
        return !userBlock.checkIsBlocked();
    }
}
