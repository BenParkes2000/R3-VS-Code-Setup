global class PrepareSandboxJAhmad implements SandboxPostCopy {
    global void runApexClass(SandboxContext context) {
        PrepareSandbox.fixUserEmail('jawad@r3.digital');
    }
}