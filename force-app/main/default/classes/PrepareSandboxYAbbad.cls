global class PrepareSandboxYAbbad implements SandboxPostCopy {
    global void runApexClass(SandboxContext context) {
        PrepareSandbox.fixUserEmail('younnis@r3.digital');
    }
}