global class PrepareSandboxBOComhrai implements SandboxPostCopy {
    global void runApexClass(SandboxContext context) {
        PrepareSandbox.fixUserEmail('bocomhrai@r3.digital');
    }
}