global class PrepareSandboxRTait implements SandboxPostCopy {
    global void runApexClass(SandboxContext context) {
        PrepareSandbox.fixUserEmail('rtait@r3.digital');
    }
}