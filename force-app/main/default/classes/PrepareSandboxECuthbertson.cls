global class PrepareSandboxECuthbertson implements SandboxPostCopy {
    global void runApexClass(SandboxContext context) {
        PrepareSandbox.fixUserEmail('ecuthbertson@r3.digital');
    }
}