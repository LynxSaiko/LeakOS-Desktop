#!/bin/bash
# Firefox 102 System-Wide Configuration Setup

FIREFOX_DIR="/usr/share/firefox"

# Create autoconfig
sudo mkdir -p $FIREFOX_DIR/defaults/pref/
sudo cat > $FIREFOX_DIR/defaults/pref/autoconfig.js << 'EOF'
pref("general.config.filename", "firefox.cfg");
pref("general.config.obscure_value", 0);
pref("general.config.sandbox_enabled", false);
EOF

# Create main config
sudo cat > $FIREFOX_DIR/firefox.cfg << 'EOF'
// Firefox 102 ESR System Configuration
try {
  // Updates
  lockPref("app.update.auto", false);
  lockPref("app.update.enabled", false);
  
  // Performance
  lockPref("browser.cache.disk.enable", true);
  lockPref("browser.cache.memory.enable", true);
  lockPref("browser.sessionstore.interval", 30000);
  
  // Privacy
  lockPref("toolkit.telemetry.enabled", false);
  lockPref("datareporting.healthreport.uploadEnabled", false);
  
  // Interface
  lockPref("browser.startup.homepage", "about:blank");
  lockPref("browser.newtabpage.enabled", false);
  
  // Hardware
  lockPref("layers.acceleration.disabled", true);
  
  // Firefox 102 specific
  lockPref("browser.aboutwelcome.enabled", false);
  lockPref("extensions.getAddons.showPane", false);
  
} catch(e) {
  displayError("firefox.cfg", e);
}
EOF

# Buat directory distribution
sudo mkdir -p /usr/share/firefox/distribution

# Buat policies.json
sudo cat > /usr/share/firefox/distribution/policies.json << 'EOF'
{
  "policies": {
    "DisableAppUpdate": true,
    "DisableFirefoxAccounts": true,
    "DisableFirefoxStudies": true,
    "DisablePocket": true,
    "DisableTelemetry": true,
    "DisableFormHistory": false,
    "DisplayBookmarksToolbar": true,
    "DisplayMenuBar": "default-off",
    "DontCheckDefaultBrowser": true,
    "Homepage": {
      "URL": "about:blank",
      "Locked": false,
      "StartPage": "homepage"
    },
    "OfferToSaveLogins": false,
    "OverrideFirstRunPage": "",
    "OverridePostUpdatePage": "",
    "PasswordManagerEnabled": false,
    "Preferences": {
      "browser.cache.disk.enable": {
        "Value": true
      },
      "browser.cache.memory.enable": {
        "Value": true
      },
      "layers.acceleration.disabled": {
        "Value": true
      }
    }
  }
}
EOF

# Set permissions
sudo chmod 644 $FIREFOX_DIR/defaults/pref/autoconfig.js
sudo chmod 644 $FIREFOX_DIR/firefox.cfg

echo "Firefox system configuration installed successfully!"
