package com.easybus.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.easybus.entity.Permission;
import com.easybus.service.PermissionService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/permissions")
public class PermissionController {

    @Autowired PermissionService permissionService;

   
        // -------------------- CREATE --------------------

        // ✅ Create single permission
        @PostMapping("/create")
        public ResponseEntity<Permission> create(@RequestBody Permission permission) {
            return ResponseEntity.ok(permissionService.createPermission(permission));
        }

        // ✅ Create multiple permissions (bulk)
        @PostMapping("/create/bulk")
        public ResponseEntity<List<Permission>> createBulk(@RequestBody List<Permission> permissions) {
            return ResponseEntity.ok(permissionService.createPermissions(permissions));
        }

        // -------------------- UPDATE --------------------

        @PutMapping("/update/{id}")
        public ResponseEntity<Permission> updatePermission(@PathVariable Long id,
                                                           @RequestBody Permission permission) {
            return ResponseEntity.ok(permissionService.updatePermission(id, permission));
        }
        // ✅ Bulk update → send list of permissions with IDs
        @PutMapping("/update/bulk")
        public ResponseEntity<List<Permission>> updateBulk(@RequestBody List<Permission> permissions) {
            return ResponseEntity.ok(permissionService.updatePermissions(permissions));
        }

        // -------------------- DELETE --------------------

        @DeleteMapping("/{id}")
        public ResponseEntity<Void> delete(@PathVariable Long id) {
            permissionService.deletePermission(id);
            return ResponseEntity.noContent().build();
        }

        // ✅ Bulk delete → send list of IDs
        @DeleteMapping("/delete/bulk")
        public ResponseEntity<Void> deleteBulk(@RequestBody List<Long> ids) {
            permissionService.deletePermissions(ids);
            return ResponseEntity.noContent().build();
        }

        // -------------------- GET --------------------

        @GetMapping("/getAlllist")
        public ResponseEntity<List<Permission>> getAll() {
            return ResponseEntity.ok(permissionService.getAllPermissions());
        }

        @GetMapping("/{id}")
        public ResponseEntity<Permission> getById(@PathVariable Long id) {
            return ResponseEntity.ok(permissionService.getPermissionById(id));
        }

        // -------------------- ASSIGN / REMOVE --------------------

        // Assign single
        @PostMapping("/assign/{roleId}/{permissionId}")
        public ResponseEntity<Void> assignPermission(@PathVariable Long roleId, @PathVariable Long permissionId) {
            permissionService.assignPermissionToRole(roleId, permissionId);
            return ResponseEntity.ok().build();
        }

        // ✅ Assign multiple permissions to a role
        @PostMapping("/assign/bulk/{roleId}")
        public ResponseEntity<Void> assignPermissions(@PathVariable Long roleId, @RequestBody List<Long> permissionIds) {
            permissionService.assignPermissionsToRole(roleId, permissionIds);
            return ResponseEntity.ok().build();
        }

        // Remove single
        @DeleteMapping("/remove/{roleId}/{permissionId}")
        public ResponseEntity<Void> removePermission(@PathVariable Long roleId, @PathVariable Long permissionId) {
            permissionService.removePermissionFromRole(roleId, permissionId);
            return ResponseEntity.noContent().build();
        }

        // ✅ Remove multiple permissions from a role
        @DeleteMapping("/remove/bulk/{roleId}")
        public ResponseEntity<Void> removePermissions(@PathVariable Long roleId, @RequestBody List<Long> permissionIds) {
            permissionService.removePermissionsFromRole(roleId, permissionIds);
            return ResponseEntity.noContent().build();
        }
    }

