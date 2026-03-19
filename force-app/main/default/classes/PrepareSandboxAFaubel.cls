global class PrepareSandboxAFaubel implements SandboxPostCopy {
    global void runApexClass(SandboxContext context) {
        PrepareSandbox.fixUserEmail('afaubel@r3.digital');
    }
}