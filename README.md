# Event Manager (Salesforce)

Event Manager è un progetto Salesforce sviluppato per gestire eventi aziendali, invitati e check-in utilizzando **Apex**, **Lightning Web Components (LWC)** e **Flow**.

Il progetto nasce come esercizio avanzato per migliorare competenze di sviluppo sulla piattaforma Salesforce e simulare la costruzione progressiva di un piccolo prodotto CRM.

---

# Obiettivo del progetto

L'obiettivo principale è costruire un'applicazione Salesforce completa che permetta di:

* gestire eventi aziendali
* invitare partecipanti
* monitorare le conferme
* registrare i check-in durante l'evento
* analizzare statistiche e partecipazione

Dal punto di vista tecnico il progetto è pensato per esercitarsi su:

* Apex development
* Lightning Web Components
* Flow automation
* Salesforce data modeling
* Git versioning e sviluppo con Salesforce CLI

---

# Tecnologie utilizzate

* Salesforce Developer Edition
* Apex
* Lightning Web Components (LWC)
* Salesforce Flow
* Salesforce CLI
* Visual Studio Code
* Git / GitHub

---

# Architettura del progetto

La struttura del progetto segue lo standard Salesforce DX.

```
force-app/
  main/
    default/
      classes/        -> Apex classes
      lwc/            -> Lightning Web Components
      objects/        -> Custom objects
      flows/          -> Salesforce Flow
      layouts/        -> Page layouts
      permissionsets/ -> Permission sets
```

---

# Data Model (prima versione)

Il sistema è basato su tre oggetti principali.

### Event

Rappresenta un evento aziendale.

Campi principali:

* Name
* Event Date
* Location
* Status (Draft, Invitations Open, Live, Closed)

---

### Guest

Rappresenta una persona invitata a un evento.

Campi principali:

* First Name
* Last Name
* Email
* Phone

---

### Invitation

Rappresenta l'invito di un guest a un evento.

Relazioni:

* Event
* Guest

Campi principali:

* Status (Invited, Confirmed, Cancelled, Attended)

---

# Setup del progetto

Clone della repository:

```
git clone <repository-url>
cd event-manager
```

Login nella org Salesforce:

```
sf org login web
```

Deploy dei metadata nella org:

```
sf project deploy start
```

---

# Roadmap del progetto

### Versione 1

* Data model base
* gestione Event
* gestione Invitation

### Versione 2

* gestione Guest
* Flow per gestione inviti

### Versione 3

* componente LWC per gestione invitati

### Versione 4

* check-in evento tramite LWC

### Versione 5

* dashboard e analytics

### Versione 6

* integrazione API esterna simulata

---

# Scopo educativo

Questo progetto è sviluppato per migliorare competenze tecniche su Salesforce e simulare lo sviluppo di una soluzione CRM reale utilizzando le best practice della piattaforma.

---

# Autore

Giordano Guidi

