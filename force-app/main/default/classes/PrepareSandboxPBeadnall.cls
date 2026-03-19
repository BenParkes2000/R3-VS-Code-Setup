global class PrepareSandboxPBeadnall implements SandboxPostCopy {
    global void runApexClass(SandboxContext context) {
        PrepareSandbox.fixUserEmail('pbeadnall@r3.digital');
    }
}