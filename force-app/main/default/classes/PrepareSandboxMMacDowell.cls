global class PrepareSandboxMMacDowell implements SandboxPostCopy {
    global void runApexClass(SandboxContext context) {
        PrepareSandbox.fixUserEmail('mmacdowell@r3.digital');
    }
}