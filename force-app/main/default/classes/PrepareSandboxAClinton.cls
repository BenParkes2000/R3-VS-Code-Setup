global class PrepareSandboxAClinton implements SandboxPostCopy {
    global void runApexClass(SandboxContext context) {
        PrepareSandbox.fixUserEmail('aclinton@r3.digital');
    }
}