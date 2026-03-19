global class PrepareSandboxASteel implements SandboxPostCopy {
    global void runApexClass(SandboxContext context) {
        PrepareSandbox.fixUserEmail('asteel@r3.digital');
    }
}