global class PrepareSandboxRCallear implements SandboxPostCopy {
    global void runApexClass(SandboxContext context) {
        PrepareSandbox.fixUserEmail('rcallear@r3.digital');
    }
}