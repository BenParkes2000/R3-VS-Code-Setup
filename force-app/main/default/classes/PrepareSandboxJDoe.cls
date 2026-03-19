global class PrepareSandboxJDoe implements SandboxPostCopy {
    global void runApexClass(SandboxContext context) {
        PrepareSandbox.fixUserEmail('jdoe@r3.digital.test');
    }
}