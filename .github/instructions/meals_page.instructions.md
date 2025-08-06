---
applyTo: '**'
---

## Objective

Integrate the camera, AI food recognition, and meal tracking logic into the provided `meals_page.dart` UI.  
- Use Riverpod for all state management.
- Omit Firestore data persistence entirely.
- MealsPage should dynamically display a list of meals added by the user.

---

## 1. Update pubspec.yaml Dependencies

Add the following packages if not already present:
- `flutter_riverpod`: For state management.
- `camera`: To access the device's camera.
- `path_provider`: To store temporary image files.
- `path`: For path manipulation.
- `google_generative_ai`: To connect to the Gemini API for image recognition.

> Run `flutter pub get` after updating.

---

## 2. Update main.dart for Camera Initialization

- Declare a `late List<CameraDescription> cameras;` global variable.
- In `main()`, after `WidgetsFlutterBinding.ensureInitialized()`, get the available cameras and store them in the `cameras` variable (use a try-catch block).
- Ensure the app is wrapped in `ProviderScope`.

---

## 3. Create Model and Riverpod Providers

- **Meal Model**:  
    Define a `Meal` class to represent a tracked meal.  
    Fields: `foodName`, `calories`, `imagePath`, `timestamp`, `mealType` (e.g., 'Breakfast', 'Lunch').

- **mealsProvider**:  
    Create a `StateNotifierProvider` to manage the in-memory list of meals (`List<Meal>`).  
    The `StateNotifier` should have a method to add a new `Meal`.

- **recognizedFoodProvider**:  
    Create a `StateProvider<String>` to temporarily hold the food name recognized by the AI.  
    Initialize with a default value like `'Identifying...'`.

- **caloriesProvider**:  
    Create a `Provider` that watches `mealsProvider` and calculates the total calories for the current day.  
    MealsPage will use this provider to update the "Today's Calories" section.

---

## 4. Create Services

- **GeminiService**:  
    Handles the Gemini API call for image recognition.  
    - Uses the `gemini-pro-vision` model.
    - Accepts an image path.
    - Returns a concise string of the food name.
    - Remember to handle the API key.

- **AiService**:  
    Wrapper service that uses `GeminiService` to provide a clean interface for the UI.

- **Riverpod Integration**:  
    Create Riverpod Providers for both `GeminiService` and `AiService`.

---

## 5. Refactor and Integrate MealsPage

- Modify the `MealsPage` widget to listen to the `mealsProvider` and `caloriesProvider`.
- **Dynamic Meal List**:  
    Replace hardcoded `_buildMealCard` widgets with a `ListView.builder` that iterates through the list of meals from `mealsProvider`.  
    Each item should be a dynamic `_buildMealCard` widget.

- **Dynamic Calories Summary**:  
    Replace hardcoded calorie values (`"1,520 / 2,000"`) with dynamic values from `caloriesProvider`.

- **Add Meal Button**:  
    Modify the `onPressed` handler for the "+ Add Meal" `TextButton`.  
    It should navigate to a new `CameraScreen` (not be empty).

---

## 6. Create New UI Screens

- **CameraScreen**:  
    Create a new `ConsumerStatefulWidget` to handle the camera.  
    - Display the camera feed.
    - Button to take a picture.
    - On press: take a picture, save to a temporary location, navigate to `RecognitionScreen` (pass image file path).

- **RecognitionScreen**:  
    Create a new `ConsumerWidget` that receives the image path.  
    - Display the captured image.
    - Use `AiService` to recognize the food, updating `recognizedFoodProvider`.
    - "Confirm and Save" button: adds new `Meal` to `mealsProvider`.
    - "Cancel / Retake" button: navigate back.

---

## 7. Final Integration and Polish

- Ensure seamless navigation between `MealsPage`, `CameraScreen`, and `RecognitionScreen`.
- Add a simple `calories` field to the `Meal` model (as `_buildMealCard` expects it).  
    You can set a dummy value initially or have the AI service return an estimated calorie count.
- Update `_buildMealCard` and `_buildSuggestionCard` in `meals_page.dart` to accept a `Meal` object and display its dynamic data.

---

This plan focuses on integrating the new functionality into your existing, well-structured UI, ensuring a consistent user experience while avoiding the complexities of Firestore for now.
