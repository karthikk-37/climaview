# ClimaView Defect & Issue Log

This document tracks all bugs identified during development, testing steps to reproduce them, and the verified resolution.

| Defect ID | Severity | Description | Steps to Reproduce | Root Cause | Status | Resolution |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **BUG-001** | High | App crash on empty search submit | 1. Tap search bar.<br>2. Leave text field blank.<br>3. Hit submit on soft keyboard. | Missing input validation before dispatching Geocoding HTTP request. | **FIXED** | Added Form validation in `CitySearchModal` checking for `value.trim().isEmpty` and `length > 60`. |
| **BUG-002** | Medium | Duplicate city added multiple times | 1. Search for "Tokyo".<br>2. Tap "Save City".<br>3. Search again and tap "Save City". | `SavedCitiesProvider` did not compare existing city IDs before appending. | **FIXED** | Implemented `alreadyExists` check in `SavedCitiesProvider.addCity()` using city ID and name comparison. |
| **BUG-003** | High | Network timeout freeze on slow 2G connection | 1. Toggle network to slow throttle.<br>2. Trigger weather fetch. | HTTP client had no timeout threshold, causing infinite loading spinners. | **FIXED** | Added `.timeout(const Duration(seconds: 10))` and mapped `TimeoutException` to user-friendly retry cards. |
| **BUG-004** | Low | Inconsistent units across screens after changing settings | 1. Change temp to Fahrenheit.<br>2. Open Saved Cities screen. | Saved cities screen was formatting raw Celsius without querying `SettingsProvider`. | **FIXED** | Injected `SettingsProvider` into `SavedCityCard` to ensure unified formatting everywhere. |
| **BUG-005** | Medium | City name text overflow on compact Android screens | 1. Search for a long city name (e.g. "Llanfairpwllgwyngyll...").<br>2. Open dashboard on 360px wide screen. | Headline lacked `overflow: TextOverflow.ellipsis` inside unconstrained Row. | **FIXED** | Wrapped city name text widget in `Flexible` with `TextOverflow.ellipsis`. |
