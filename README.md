# SPI Master Controller (Verilog)

## 📝 專案說明
這個專案是一個使用 Verilog 設計的 **SPI Master Controller**，支援標準 **SPI Mode 0** (CPOL=0, CPHA=0)。  
設計目標是能夠正確進行 **8-bit 單筆資料傳輸與接收**，並透過 RTL模擬與波形驗證功能正確性。

---

## 📂 專案結構

| 檔案 | 說明 |
|:---|:---|
| `spi_master.v` | SPI Master 主設計 (Verilog RTL) |
| `spi_master_tb.v` | Testbench 驗證用檔案 |
| `RTL_spi_master.png` | SPI Master 模組的RTL結構圖 |
| `wave_spi_master_tb.png` | ModelSim 仿真波形截圖 |

---

## 🚀 功能特色
- SPI Mode 0支援 (CPOL=0, CPHA=0)
- 單筆8-bit資料傳送與接收
- Clock Divider可設定（目前預設除4）
- 具備Start控制、Busy旗標、完成後輸出資料
- Testbench已搭配完成，ModelSim仿真通過

---

## 📸 專案圖片

### RTL架構圖
![RTL Diagram](RTL_spi_master.png)

---

### 仿真波形圖
![Simulation Waveform](wave_spi_master_tb.png)

---

## 🛠 使用方式

1. 下載或clone本專案。
2. 在ModelSim中編譯並仿真：
    ```sh
    vlog spi_master.v spi_master_tb.v
    vsim spi_master_tb
    add wave *
    run 1000ns
    ```
3. 觀察 `sclk`, `mosi`, `miso`, `cs_n` 等訊號符合SPI時序。
