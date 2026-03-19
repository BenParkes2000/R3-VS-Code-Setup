global class PrepareSandboxDHogan implements SandboxPostCopy {
    global void runApexClass(SandboxContext context) {
        PrepareSandbox.fixUserEmail('dhogan@r3.digital');
    }
}