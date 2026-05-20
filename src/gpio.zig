const BASE: usize = 0x3F000000;

pub const GPFSEL1: usize = (BASE + 0x00200004);
pub const GPSET0: usize = (BASE + 0x0020001C);
pub const GPCLR0: usize = (BASE + 0x00200028);
pub const GPPUD: usize = (BASE + 0x00200094);
pub const GPPUDCLK0: usize = (BASE + 0x00200098);

pub const AUX_ENABLES: usize = (BASE + 0x00215004);
pub const AUX_MU_IO_REG: usize = (BASE + 0x00215040);
pub const AUX_MU_IER_REG: usize = (BASE + 0x00215044);
pub const AUX_MU_IIR_REG: usize = (BASE + 0x00215048);
pub const AUX_MU_LCR_REG: usize = (BASE + 0x0021504C);
pub const AUX_MU_MCR_REG: usize = (BASE + 0x00215050);
pub const AUX_MU_LSR_REG: usize = (BASE + 0x00215054);
pub const AUX_MU_MSR_REG: usize = (BASE + 0x00215058);
pub const AUX_MU_SCRATCH: usize = (BASE + 0x0021505C);
pub const AUX_MU_CNTL_REG: usize = (BASE + 0x00215060);
pub const AUX_MU_STAT_REG: usize = (BASE + 0x00215064);
pub const AUX_MU_BAUD: usize = (BASE + 0x00215068);
