global class PrepareSandboxJHarte implements SandboxPostCopy {
    global void runApexClass(SandboxContext context) {
        PrepareSandbox.fixUserEmail('jharte@r3.digital');
    }
}