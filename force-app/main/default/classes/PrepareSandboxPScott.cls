global class PrepareSandboxPScott implements SandboxPostCopy {
    global void runApexClass(SandboxContext context) {
        PrepareSandbox.fixUserEmail('pscott@r3.digital');
    }
}