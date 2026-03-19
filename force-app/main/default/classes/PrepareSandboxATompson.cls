global class PrepareSandboxATompson implements SandboxPostCopy {
    global void runApexClass(SandboxContext context) {
        PrepareSandbox.fixUserEmail('atompson@r3.digital');
    }
}