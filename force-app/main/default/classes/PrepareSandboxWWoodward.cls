global class PrepareSandboxWWoodward implements SandboxPostCopy {
    global void runApexClass(SandboxContext context) {
        PrepareSandbox.fixUserEmail('wwoodward@r3.digital');
    }
}