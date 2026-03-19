global class PrepareSandboxMMorgan implements SandboxPostCopy {
    global void runApexClass(SandboxContext context) {
        PrepareSandbox.fixUserEmail('mmorgan@r3.digital');
    }
}