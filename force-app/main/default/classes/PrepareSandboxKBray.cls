global class PrepareSandboxKBray implements SandboxPostCopy {
    global void runApexClass(SandboxContext context) {
        PrepareSandbox.fixUserEmail('kbray@r3.digital');
    }
}