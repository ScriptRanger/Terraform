#!/bin/bash

# Sicherstellen, dass das Skript als root läuft
if [ "$EUID" -ne 0 ]; then
  echo "❌ Bitte führe das Skript als root aus (z. B. mit sudo)"
  exit 1
fi

echo "🔄 System wird aktualisiert..."
apt-get update && apt-get install -y gnupg software-properties-common curl wget lsb-release

echo "🔐 GPG-Key wird hinzugefügt..."
wget -qO- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "📦 Repository wird hinzugefügt..."
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" > /etc/apt/sources.list.d/hashicorp.list

# Erwarteten Fingerprint setzen
EXPECTED_FINGERPRINT="798AEC654E5C15428C8E42EEAA16FCBCA621E701"

# Tatsächlichen Fingerprint extrahieren
ACTUAL_FINGERPRINT=$(gpg --no-default-keyring \
  --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
  --list-keys --with-fingerprint --with-colons | \
  awk -F: '/^fpr/ { print $10; exit }')

echo "🔍 Erwarteter Fingerprint:   $EXPECTED_FINGERPRINT"
echo "🔍 Tatsächlicher Fingerprint: $ACTUAL_FINGERPRINT"

# Vergleich
if [[ "$ACTUAL_FINGERPRINT" != "$EXPECTED_FINGERPRINT" ]]; then
  echo "❌ Fehler: Der GPG-Schlüssel stimmt NICHT mit dem erwarteten Fingerabdruck überein!"
  exit 1
else
  echo "✅ GPG-Schlüssel wurde erfolgreich verifiziert."
fi

echo "📥 Terraform wird installiert..."
apt-get update && apt-get install -y terraform

echo "🧪 Version prüfen:"
terraform -v

echo "⚙️ Autocomplete aktivieren..."
terraform -install-autocomplete

echo "✅ Terraform wurde erfolgreich installiert!"
echo "ℹ️ Starte deine Shell neu oder führe 'exec \$SHELL' aus, um Autocomplete zu aktivieren."
