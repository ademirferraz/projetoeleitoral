RESUMO DAS TENTATIVAS DE EMULADOR - 10/08/2026
==============================================

MAQUINA: Lenovo IdeaPad 80YH (i3-6006U 2c/4t), Windows 10.0.19045
AVD alvo: Pixel_7 (system-images\android-36.1\google_apis_playstore\x86_64)
Nota: uma das tentativas (12:29) usou AVD Pixel_7_2 (android-37.0 ps16k).

TENTATIVAS:
 1) 12:09  -no-snapshot  -gpu swiftshader_indirect  (script ps1)
 2) 12:31  -no-snapshot  -gpu host
 3) 12:51  (com snapshot default_boot) -gpu auto
 4) 13:10  -no-snapshot  -accel off (TCG puro)

SINTOMA: em todas, qemu-system-x86_64 ativo com CPU crescendo
(139s -> 705s -> 763s), 1.5-2GB RAM, mas adb devices sempre
"emulator-5554 offline"; guest nunca completa boot; disco do AVD
(userdata-qemu.img.qcow2) nunca recebe escrita nova; qemu morto
externamente pelo terminal integrado apos ~15-20min.

ACELERACAO (log emulator.log, tentativa 3):
  DEBUG | Checking whether Windows Hypervisor Platform (WHPX) is available.
  DEBUG | WHvGetCapability found. Querying WHPX capabilities...
  DEBUG | WHPX (10.0.19045) is installed and usable.
  DEBUG | CPU Acceleration: working
  DEBUG | CPU Acceleration status: WHPX(10.0.19045) is installed and usable.
  INFO  | WHPX on Windows 10.0.19045 detected.
  INFO  | Windows Hypervisor Platform accelerator is operational
  INFO  | Checking: hasCompatibleHypervisor
  INFO  |    Ok: Hypervisor compatibility to run avd: Pixel_7 are met

GPU/VULKAN (tentativa 1, swiftshader):
  WARNING | Please update the emulator to one that supports the feature(s): VulkanVirtualQueue
  INFO    | Critical: Failed to load opengl32sw (Nao foi possivel encontrar o modulo especificado.) (:0, )
  INFO    | Warning: Software OpenGL failed. Falling back to system OpenGL. (:0, )
  VERBOSE | Failed to load [...\lib64\vulkan\vulkan-1.dll]. Error string: []
  VERBOSE | Failed to load [...\lib\vulkan\vulkan-1.dll]. Error string: []
  INFO    | Storing crashdata in: C:\Users\Usu�rio\AppData\Local\Temp\AndroidEmulator\emu-crash-36.4.9.db, detection is enabled

OUTROS:
  WARNING | (metrics) failed to open a new log file
  DEBUG   | Failed obtain protocol version from ...\platform-tools\adb.exe
  ERROR   | Failed to retrieve exit code due to: Identificador invalido.
  DEBUG   | Crash info: hw.gpu.enabled=yes / hw.cpu.ncore=2 / disk.dataPartition.size=6G
  FIM LOG: repeticoes de "No acpi ini file provided, using default"
  (sem crash report util no emu-crash-36.4.9.db; sem mensagem de segfault)

HIPOTESE (a confirmar): conflito WHPX/Hyper-V no Windows 10.0.19045.
  - WMI: HypervisorPresent=True (Hyper-V ativo) mas VirtualizationFirmwareEnabled=False
  - accel-check diz WHPX "installed and usable", porem o guest fica
    preso em offline -> acelera do WHPX nao esta sendo efetiva ou o
    host esta em nested virtualization degradado.
  - i3-6006U (2 nucleos) + imagem API 36/37 + Play Store: boot muito
    lento mesmo com acel adeq; com WHPX quebrado, nunca completa.

COMO RETOMAR (quando for prioridade):
  a) Desativar Hyper-V: bcdedit /set hypervisorlaunchtype off + reboot
     (libera VT-x p/ HAXM/WHPX direto). Requer reiniciar o Windows.
  b) Ou rodar emulador dentro de maquina com virtualizacao dedicada.
  c) Alternativa de baixo custo: aparelho Android fisico via USB debug.

Logs completos guardados em:
  C:\Windows\Temp\opencode\emulator.log         (1223 linhas, tent. 3)
  C:\Windows\Temp\opencode\emulator_tcg.log     (90931 bytes, tent. 4)
  C:\Windows\Temp\opencode\emulator_err.log     (tent. 1)
