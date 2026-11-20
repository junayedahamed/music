# Full Flutter Application Audit, Refactoring & Performance Optimization

Act as a **Senior Flutter Architect and Performance Engineer**. Your task is to conduct a comprehensive audit of the entire existing Flutter application, refactor its architecture, improve code quality, and optimize overall application performance without breaking existing functionality.

## 1. Strict File Size Limit

- Every Dart source file must contain **250 lines of code or fewer**.
- Audit every Dart file throughout the project, including screens, controllers, services, repositories, widgets, models, and utilities.
- If any file exceeds 250 lines, refactor it into smaller, logically separated files.
- Extract reusable widgets, helper methods, business logic, models, and supporting components into separate files where appropriate.
- Maintain clear separation of responsibilities.
- Avoid creating unnecessary files just to satisfy the line limit.
- Each file should have a single, well-defined responsibility.
- Keep file names descriptive and consistent with Flutter/Dart naming conventions.

**Important:** The 250-line limit is mandatory, not a recommendation. Do not leave oversized Dart files untouched.

## 2. State Management — GetX Is Mandatory

The application must consistently follow the existing GetX architecture.

- `setState()` is strictly prohibited for application-level state management.
- Use GetX Controllers, `Rx` variables, `Obx`, `GetBuilder`, and appropriate GetX reactive mechanisms.
- For small, isolated UI-only states, `setState()` is acceptable only when using GetX would introduce unnecessary complexity.
- Move business logic and state-related operations out of UI widgets and into their respective controllers.
- Avoid unnecessary reactive variables and excessive widget rebuilds.
- Use the most appropriate GetX update mechanism for each use case.
- Do not introduce multiple controllers managing the same state.
- Maintain a clear separation between UI, state management, business logic, and data access.

## 3. Architecture & Code Organization

Review the entire project and improve its architecture while preserving the existing implementation wherever possible.

- Maintain a scalable, modular, and maintainable folder structure.
- Follow separation of concerns and the Single Responsibility Principle.
- Keep UI components independent of business logic.
- Separate API calls, data processing, and business rules from controllers and widgets.
- Extract reusable components into shared widget files.
- Avoid duplicated code and unnecessary dependencies.
- Maintain consistent dependency injection and controller lifecycle management.
- Preserve the existing navigation and routing architecture.

Do not rewrite the entire application unnecessarily. Refactor incrementally and intelligently.

## 4. Performance Optimization

Perform a comprehensive performance audit and optimize the following areas:

**UI Performance**

- Minimize unnecessary widget rebuilds.
- Optimize reactive GetX subscriptions.
- Use `const` constructors wherever possible.
- Avoid expensive operations inside `build()` methods.
- Use lazy loading for long lists and large datasets.
- Optimize `ListView`, `GridView`, and other scrolling components.
- Use appropriate widget extraction and caching techniques.
- Prevent unnecessary widget tree complexity.

**Memory Management**

- Properly dispose of controllers, streams, subscriptions, animation controllers, focus nodes, and text editing controllers when their lifecycle ends.
- Prevent memory leaks and duplicate listeners.
- Avoid unnecessary object creation.
- Ensure GetX controllers are registered and removed appropriately.

**API & Data Performance**

- Avoid duplicate API requests.
- Implement appropriate caching where beneficial.
- Prevent unnecessary network calls.
- Handle loading, success, empty, and error states efficiently.
- Optimize JSON parsing and data transformation.
- Avoid blocking the main UI thread with expensive operations.

**Images & Assets**

- Optimize image loading and caching.
- Use appropriate image dimensions and quality.
- Avoid loading unnecessarily large images.
- Prevent unnecessary image decoding and rendering.

## 5. Code Quality & Best Practices

- Follow current stable Flutter and Dart best practices.
- Do not use deprecated Flutter or Dart APIs.
- Maintain null safety.
- Use meaningful variable, method, class, and file names.
- Remove unused imports, variables, methods, and dependencies where safe.
- Avoid deeply nested conditional statements.
- Replace unnecessary complex logic with smaller, reusable methods.
- Handle exceptions properly.
- Avoid hardcoded values where centralized configuration is appropriate.
- Maintain consistent formatting and linting standards.

## 6. Preserve Existing Functionality

This is an existing application, so functionality must not be compromised.

- Do not remove existing features.
- Do not change the UI design or user experience unless necessary for performance or bug fixes.
- Preserve existing API contracts and request/response structures.
- Maintain existing GetX navigation, routing, and dependency injection behavior.
- Preserve authentication, session management, and application security.
- Ensure all existing screens and workflows continue to work.
- Avoid introducing unnecessary package dependencies.

## 7. Security & Stability

Review security-sensitive implementation areas:

- Secure token and credential handling.
- Avoid logging sensitive information.
- Validate API responses and user inputs.
- Handle network failures and unexpected exceptions.
- Prevent duplicate submissions and unintended repeated actions.
- Ensure proper lifecycle management.
- Avoid exposing sensitive application data.

## 8. Execution Strategy

Perform the work systematically.

**Phase 1 — Full Project Audit**

- Inspect the complete project structure.
- Identify every Dart file exceeding 250 lines.
- Find all `setState()` usages.
- Identify inefficient GetX implementations.
- Detect duplicated logic, memory leaks, unnecessary rebuilds, and performance bottlenecks.
- Prepare a prioritized refactoring plan.

**Phase 2 — Refactoring**

- Refactor oversized files into smaller, meaningful components.
- Migrate application-level `setState()` usage to GetX.
- Separate UI, controllers, services, repositories, and models.
- Remove duplicated and unnecessary code.
- Improve dependency and lifecycle management.

**Phase 3 — Performance Optimization**

- Optimize widget rebuilds, API operations, image loading, memory usage, and scrolling performance.
- Apply appropriate caching and lazy-loading strategies.
- Address identified performance bottlenecks.

**Phase 4 — Validation**
After each major refactoring stage:

- Run `flutter analyze`.
- Run relevant unit and widget tests.
- Fix newly introduced errors and warnings.
- Verify imports and dependency registrations.
- Ensure the application builds successfully.
- Verify that existing features remain functional.

## 9. Final Audit Report

When the work is complete, provide a detailed report containing:

1. Total Dart files audited.
2. Files that originally exceeded 250 lines.
3. Files created during refactoring.
4. Files modified and their responsibilities.
5. All remaining `setState()` usages with explanations.
6. GetX state management improvements.
7. Performance optimizations implemented.
8. Memory management improvements.
9. Deprecated APIs and unused code removed.
10. Flutter analyze results.
11. Test and build results.
12. Any remaining issues that require attention.

## 10. Mandatory Acceptance Criteria

The task is considered complete only when:

- [ ] Every Dart source file contains no more than 250 lines.
- [ ] Application-level `setState()` usage has been eliminated.
- [ ] GetX is consistently used for application state management.
- [ ] Controllers and services have clear responsibilities.
- [ ] Unnecessary widget rebuilds have been minimized.
- [ ] Resource disposal and lifecycle management are correct.
- [ ] Duplicate code and unnecessary dependencies are removed.
- [ ] No existing application functionality has been broken.
- [ ] `flutter analyze` has been executed and new issues resolved.
- [ ] The application builds successfully.

**Final Instruction:** Do not simply inspect the application and provide suggestions. Actually perform the audit, refactoring, and optimization. Work through the entire project systematically, not just the currently open files. Do not skip large files or leave known issues unresolved without documenting the reason.

Prioritize maintainability, performance, stability, and production-grade code quality over unnecessary architectural complexity.
