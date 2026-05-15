## Change Summary
Brief description of what changed and why.

## Role
- [ ] Systems Engineer (SE) — architecture/requirements
- [ ] Software Engineer (SWE) — design/codegen
- [ ] Verification Engineer (VE) — tests/reports

## Checklist

### All roles
- [ ] CI passes (verify job green)
- [ ] No direct edits to generated code
- [ ] Commit messages follow [type][domain] format

### SE changes
- [ ] Requirement links updated for modified components
- [ ] SLDD changes do not break model compilation
- [ ] Variant configurations tested with setVariantConfig

### SWE changes
- [ ] Code generation re-run after model changes
- [ ] No manual edits to GeneratedCode/
- [ ] MAAB check passes on modified models

### VE changes
- [ ] New test cases linked to requirements
- [ ] Decision coverage >= 85% after changes
- [ ] Coverage report regenerated

## Test Results
Paste relevant test output or link to CI run.
