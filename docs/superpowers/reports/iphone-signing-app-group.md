# iPhone signing and App Group runtime verification

## CI signing boundary

GitHub Actions produces an **unsigned IPA**. The repository must not contain signing certificates, private keys, `.p12` files, or provisioning profiles. Signing is performed on the owner's iPhone with Feather or ESign so certificate material remains on the device.

A successful CI build or static entitlement check is not evidence that the IPA has been signed, installed, or that App Group communication works at runtime.

## Sign and install on iPhone

1. Download the `Fresh-Unsigned-IPA` artifact from the successful Build Fresh Unsigned IPA workflow run.
2. Verify the downloaded IPA SHA-256 against the accompanying `.sha256` file using a trusted local checksum utility, if available.
3. Import the IPA into Feather or ESign on the iPhone.
4. Select the owner's signing certificate and the matching provisioning profile for the application and keyboard extension. Do not use a profile that omits the App Group entitlement.
5. Confirm the signer preserves both bundle identifiers:
   - App: `app.personal.PersonalKeyboard`
   - Keyboard extension: `app.personal.PersonalKeyboard.KeyboardExtension`
6. Confirm the signed app and extension both retain `group.app.personal.PersonalKeyboard` in their effective entitlements. The signer must sign the embedded extension as well as the containing app.
7. Sign, install, and launch the container app. Enable Naqra in iOS Settings → General → Keyboard → Keyboards, then allow the required access only if the app's features require it.

Feather and ESign labels and screens can change between releases; follow the current app UI rather than relying on fixed button names.

## App Group runtime test

Perform this test on the physical iPhone after installation:

1. In the container app, change a setting that is shared with the keyboard (for example, the theme or number-row setting) and save it.
2. Open a text field in another app and switch to Naqra.
3. Confirm the keyboard reflects the newly saved setting without reinstalling or relaunching the app.
4. Change the setting again from the container app, return to the keyboard, and confirm the second change is reflected.
5. If clipboard history is enabled intentionally, add a harmless test string, confirm it is visible in the keyboard, clear it, and confirm it disappears. Do not use passwords, personal messages, or sensitive clipboard contents for this test.
6. Record the iOS version, signer app/version, certificate/profile type, IPA SHA-256, installation result, and each observed pass/fail result.

## Evidence status

Until the owner performs the physical-device procedure and records its result, signing, installation, keyboard activation, and App Group runtime behavior remain **unverified**. CI checks of source entitlements and bundle identifiers are static checks only.
