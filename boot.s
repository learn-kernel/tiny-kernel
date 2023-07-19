!   boot.s
!
! It then loads the system at 0x10000, using BIOS interrupts. Thereafter
! it disables all interrupts, changes to protected mode, and calls the 
!
! 1. PC上电后，80x86结构的 CPU 进入实模式，并从地址 0XFFFF0 开始自动执行代码(这个就是BIOS代码)
! 2. BIOS 在物理地址 0 处开始初始化中断向量。
! 3. BIOS 将可启动设备的第一个扇区读入内存地址 0x7C00 处(一般是汇编写的boot/bootsec.S)，并跳转到这个地方，并开始执行这段 Boot 代码
! 4. Boot 将自己复制到绝对地址 0x90000处，并把 boot/setup.S 读取到它的下 2KB 字节代码读到内存 0x90200 处，而内核其它部分则被读入 0x10000 处。在系统加载期间将显示 "Loading ..."。然后控制权将传递给 boot/Setup.S 中的代码，这时另一个实模式汇编语言程序。
! 5. Setup.S 识别主机的某些特性以及 vga 卡的类型，它会要求用户为控制台选择显示模式。最后将整个系统从地址 0x10000 移至 0x1000 处，进入保护模式并跳转至系统的余下部分(在0x1000处)
! 6. 内核解压缩。0X1000 处的代码来自 zBoot/head.S，它初始化寄存器并调用 decompress_kernel()<它依次由 zBoot/inflate.c、zBoot/unzip.c、zBoot/misc.c组成>。被解压的数据存放在地址 0x10000处(1兆)，这也是Linux不能运行于少于 2MB 内存的主要原因。
!
!
! x86 实模式寻址为了兼容 8086(8086是16位cpu)，20位地址总线可寻址 1M 内存空间。寻址方式：段基址+偏移，段基址保存在: CS、DS、ES等段寄存器内，相当于寻址的高16位，
!  而偏移是内部16位总线提供，在送往外部地址总线时候，段基址和偏移合成20位地址，来寻址 1M 的物理地址空间。
! 合成方式：段基址左移4位，然后加上偏移地址。但还不是一般的相加，由于相加前段基址已经左移4位，变成20位(低四位是0)，而偏移还是16位，实际上是段基址和偏移的高12位相加，偏移的低4位不变。
!  如： 段基址左移4位后   -->  0x 8880:0
!        偏移地址(0x0440) -->  0x  044:0
!        外部总线20位地址 -->  0x 88c4:0
!
! 8086/8088的寻址问题:
!    8088和8086都是16位CPU，它们都是由两个8085(8位)微处理器并联实现的，每个8085都有它自己的8位数据和16位寻址能力。当时，8088有40个引脚，intel因此确定了20条地址线(1MB寻址)，16位数据线需要和20条地址线中的16位复用(分时复用)，具体实现如下：
!        把 1024k(20位) 地址空间分成16字节的段，共 64K 个段(8位)，用一个8085的16位寻址寄存器做地址偏移寄存器 —— 一个8085的地址寄存器(段地址 —— 就是16字节的段的序号)左移 4 位(x 16 = 16字节小段的首地址)，加上另一个 8085 的地址寄存器就可以。
!


BOOTSEG = 0x07c0                    ! BIOS 读取可启动设备第一扇区内容放到内存地址 0x7c00 处
SYSSEG  = 0x1000                    ! system loaded at 0x10000 (65536).
SYSLEN  = 17                        ! sectors occupied.

entry start
start:
    jmpi    go,#BOOTSEG             ! jmpi: 段间跳转指令，用于 x86 实模式下，假设当前CS==00h，执行此指令后将跳转到段CS=0x0c70，段也会变为 0x0c70，接下来将执行 0x0c70:go处指令
go: mov ax,cs                       ! 
    mov ds,ax
    mov ss,ax
    mov sp,#0x400       ! arbitrary value >>512

! ok, we've written the message, now
load_system:
    mov dx,#0x0000
    mov cx,#0x0002
    mov ax,#SYSSEG
    mov es,ax
    xor bx,bx
    mov ax,#0x200+SYSLEN
    int     0x13
    jnc ok_load
die:    jmp die

! now we want to move to protected mode ...
ok_load:
    cli         ! no interrupts allowed !
    mov ax, #SYSSEG
    mov ds, ax
    xor ax, ax
    mov es, ax
    mov cx, #0x2000
    sub si,si
    sub di,di
    rep
    movw
    mov ax, #BOOTSEG
    mov ds, ax
    lidt    idt_48      ! load idt with 0,0
    lgdt    gdt_48      ! load gdt with whatever appropriate

! absolute address 0x00000, in 32-bit protected mode.
    mov ax,#0x0001  ! protected mode (PE) bit
    lmsw    ax      ! This is it!
    jmpi    0,8     ! jmp offset 0 of segment 8 (cs)

gdt:    .word   0,0,0,0     ! dummy

    .word   0x07FF      ! 8Mb - limit=2047 (2048*4096=8Mb)
    .word   0x0000      ! base address=0x00000
    .word   0x9A00      ! code read/exec
    .word   0x00C0      ! granularity=4096, 386

    .word   0x07FF      ! 8Mb - limit=2047 (2048*4096=8Mb)
    .word   0x0000      ! base address=0x00000
    .word   0x9200      ! data read/write
    .word   0x00C0      ! granularity=4096, 386

idt_48: .word   0       ! idt limit=0
    .word   0,0     ! idt base=0L
gdt_48: .word   0x7ff       ! gdt limit=2048, 256 GDT entries
    .word   0x7c00+gdt,0    ! gdt base = 07xxx
.org 510
    .word   0xAA55

