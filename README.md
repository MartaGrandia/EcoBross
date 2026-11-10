# ♻️ 🗑️ EcoBross

> A smart household recycling ecosystem combining a cross-platform Flutter mobile application, an Arduino-driven IoT bin, and a relational database for automated waste sorting.

## 📖 Overview

`EcoBross` was developed as my Bachelor's Thesis (TFG) at **Universitat Pompeu Fabra (UPF)** for the B.Sc. in Audiovisual Systems Communication Engineering (2019–2020). 

The project addresses household recycling friction caused by lack of sorting knowledge or space. By combining barcode scanning, real-time Bluetooth communication, and an automated multi-compartment bin, `EcoBross` identifies product materials upon scanning and physically opens the designated disposal compartment.

---

## ⚙️ System Architecture & Tech Stack

- **Mobile Application:** Built with **Flutter (Dart)** for cross-platform compatibility (Android/iOS). Handles barcode recognition, Bluetooth pairing, user history, and gamification rewards.
- **Embedded Hardware:** **Arduino UNO**, **HC-05 Bluetooth module**, and **Servomotors** controlling 3 physical lid mechanisms (Plastic/Metal, Paper/Cardboard, Organic/General).
- **Backend & Data Layer:** **JavaScript / Node.js**, **MySQL (via MAMP)** relational database hosting product barcoding tables and scan history, tested via **Postman**.

---

## ✨ Key Features & Functionality

- **Barcode Material Recognition:** Scans standard commercial product barcodes and retrieves material classification (`Inseparable`, `Separable`, or `Unrecognized`).
- **Automated Lid Actuation:** Transmits sorting signals over Bluetooth serial to actuate specific Arduino servomotors, opening the corresponding bin slot automatically.
- **Collaborative Product Registry:** Allows users to submit new unknown barcodes and material metadata directly from the app to populate the community database.
- **Gamification & Scan Logs:** Tracks user recycling activity, maintains scan timestamps, and rewards consistent recycling goals.

---

## 🛠️ Hardware Circuit & Pinout Setup

| Component | Arduino Pin | Description |
| :--- | :--- | :--- |
| **HC-05 Bluetooth TX** | `Pin 2 (RX)` | Serial data reception from mobile app. |
| **HC-05 Bluetooth RX** | `Pin 3 (TX)` | Serial data transmission. |
| **Servo 1 (Plastic / Metal)** | `Pin 9 (PWM)` | Controls compartment lid 1 ($0^\circ \rightarrow 90^\circ$). |
| **Servo 2 (Paper / Cardboard)**| `Pin 10 (PWM)`| Controls compartment lid 2 ($0^\circ \rightarrow 90^\circ$). |
| **Servo 3 (Organic / Glass)** | `Pin 11 (PWM)`| Controls compartment lid 3 ($0^\circ \rightarrow 90^\circ$). |

---

## 📂 Repository Structure

```text
.
├── docs/                             # Documentación del Trabajo de Fin de Grado (UPF)
│   ├── diagramas/
│   │   ├── database_schema_erd.png   # Modelo Entidad-Relación de la base de datos MySQL
│   │   └── hardware_circuit_schematic.png # Esquema eléctrico y conexionado del Arduino
│   ├── EcoBross_Bachelor_Thesis_UPF.pdf   # Memoria completa de la tesis
│   └── ecobross_thesis_presentation.pptx # Presentación del proyecto
├── Ecobross/                         # Proyecto principal de la aplicación y backend
│   ├── android/                      # Configuración y proyecto nativo Android
│   ├── assets/                       # Logotipos y recursos visuales de la aplicación
│   ├── backend/                      # Servidor API REST en Node.js / Express
│   │   ├── app.js                    # Endpoints y lógica de conexión a la BDD
│   │   ├── package.json
│   │   └── package-lock.json
│   ├── ios/                          # Configuración y proyecto nativo iOS (Runner)
│   ├── lib/
│   │   └── main.dart                 # Código fuente y UI principal en Flutter (Dart)
│   ├── test/                         # Pruebas unitarias y de widgets
│   ├── pubspec.yaml                  # Configuración de dependencias y assets de Flutter
│   └── pubspec.lock
└── README.md
```
---

## 🧠 Engineering Key Takeaways

- **IoT Communication Protocols:** Integrated low-power Bluetooth serial transmission (`HC-05`) between mobile application logic and microcontrollers.
- **Full-Stack Hardware Integration:** Built an end-to-end pipeline connecting physical hardware actuators with a remote relational database and mobile UI.
- **User-Centric Systems Design:** Applied gamification and collaborative data entry models to solve real-world user adoption barriers in waste recycling.
