global class PrepareSandboxOVivian implements SandboxPostCopy {
    global void runApexClass(SandboxContext context) {
        PrepareSandbox.fixUserEmail('ovivian@r3.digital');
    }
}