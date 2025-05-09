# 💧 ForYou – Apple Watch Water Reminder App

**ForYou** is a minimalist water reminder app designed specifically for Apple Watch. It helps you stay hydrated throughout the day by logging water intake, scheduling reminders, and tracking your progress—all from your wrist.

---

## 📱 Features

- ✅ Log water intake with a single tap
- 🔔 Schedule hydration reminders
- ⏱️ Adjustable normal and shortened reminder intervals
- 📊 View total water consumed, skipped reminders, and time until next reminder
- ⚙️ Settings page for interval customization
- 💾 Uses `@AppStorage` for persistent data across launches

---

## 🛠️ Built With

- **SwiftUI**
- **watchOS 10+**
- **MVVM architecture**
- **Xcode Previews**
- **EnvironmentObject for shared state**

---

## 📂 Project Structure

```
ForYou Watch App/
├── ContentView.swift          # Main interface with water logging and stats
├── SettingsView.swift         # Allows customizing reminder intervals
├── ReminderManager.swift      # Core logic for reminders and tracking
├── ForYouApp.swift            # Entry point
```

---

## 🧪 Preview Setup

To enable SwiftUI previews:

1. Add `.environmentObject(ReminderManager.shared)` to all previews:
   ```swift
   #Preview {
       ContentView()
           .environmentObject(ReminderManager.shared)
   }
   ```

2. Make sure `ReminderManager.shared` exists and is accessible as a singleton or pass an instance as needed.

---

## ⚠️ watchOS Notes

- `TextField` must use `.keyboardType(.numberPad)` **without** errors—ensure targeting watchOS 10+.
- `Menu` is **unavailable** on watchOS. Use alternative layouts like `List` or multiple buttons with spacing.
- Avoid excessive `.padding()`—prefer `Spacer()` or `Form` to manage layout on small screens.

---

## ✅ TODO

- [ ] Add haptics for feedback
- [ ] Add iOS companion app
- [ ] Implement daily hydration goal
- [ ] Add health integration with HealthKit (optional)

---

## 📄 License

MIT License. Feel free to use and modify for your own watchOS projects.

---

## ✨ Author

**Aarya Raut** – [GitHub](https://github.com/your-username)

