# Value Behavior Documentation

This document provides comprehensive information about how different values behave in the MarkdownToDocx styling configuration system, including edge cases, limitations, and potential issues.

## 📏 Unit Conversion Behavior

### Supported Units and Conversion Factors

| Unit | Conversion Factor | Example | Result |
|------|------------------|---------|--------|
| **Inches** | 1440 twips/inch | `.inches(1.0)` | 1440 twips |
| **Points** | 20 twips/point | `.points(12.0)` | 240 twips |
| **Centimeters** | 566.93 twips/cm | `.centimeters(2.54)` | 1440 twips |
| **Millimeters** | 56.69 twips/mm | `.millimeters(25.4)` | 1439 twips |
| **Twips** | 1 twip/twip | `.twips(1440)` | 1440 twips |

### Precision and Rounding

**Important**: All unit conversions use **truncation** (not rounding) when converting to integers.

```swift
// Examples of truncation behavior:
Measurement.points(0.499).twips  // = 9 (not 10)
Measurement.points(0.501).twips  // = 10
Measurement.points(0.999).twips  // = 19 (not 20)
Measurement.points(1.001).twips  // = 20
```

## 🎯 Value Range Behavior

### ✅ Supported Values

| Value Type | Range | Behavior |
|------------|-------|----------|
| **Positive Values** | 0.0 to ∞ | ✅ Fully supported |
| **Negative Values** | -∞ to 0.0 | ✅ Supported (preserved) |
| **Zero Values** | 0.0 | ✅ Supported |
| **Fractional Values** | Any decimal | ✅ Supported |
| **Large Values** | Up to Int.max | ✅ Supported |

### ⚠️ Edge Cases and Limitations

#### Very Small Values
Values smaller than the conversion precision will result in 0 twips:

```swift
Measurement.inches(0.0001).twips  // = 0 (too small)
Measurement.points(0.01).twips    // = 0 (too small)
Measurement.centimeters(0.001).twips // = 0 (too small)
```

#### Unit Conversion Precision
Different units have different precision levels:

- **Inches**: Most precise (1440 twips/inch)
- **Points**: Good precision (20 twips/point)
- **Centimeters**: Moderate precision (566.93 twips/cm)
- **Millimeters**: Lower precision (56.69 twips/mm)

## 🔤 Font Size Behavior

### Font Size Conversion
Font sizes are converted using a special formula: `(points * 20) / 10`

```swift
// Examples:
UserFriendlyFontConfig(size: .points(6.0)).toFontConfig().size   // = 12
UserFriendlyFontConfig(size: .points(12.0)).toFontConfig().size  // = 24
UserFriendlyFontConfig(size: .points(72.0)).toFontConfig().size  // = 144
UserFriendlyFontConfig(size: .points(1000.0)).toFontConfig().size // = 2000
```

### Font Size Limitations
- **Minimum**: 0 points (results in 0 half-points)
- **Maximum**: No practical limit (tested up to 1000pt successfully)
- **Fractional sizes**: Supported but may truncate

## 🖼️ Border Width Behavior

### Border Width Conversion
Border widths use the same conversion as font sizes: `(points * 20) / 10`

```swift
// Examples:
UserFriendlyBorderSide(width: .points(0.25)).toBorderSide().width  // = 0 (truncated)
UserFriendlyBorderSide(width: .points(1.0)).toBorderSide().width   // = 2 (truncated)
UserFriendlyBorderSide(width: .points(10.0)).toBorderSide().width  // = 20 (truncated)
```

### Border Width Limitations
- **Minimum effective width**: 0.5 points (results in 1 twip)
- **Very thin borders**: May appear invisible if too small
- **Thick borders**: No practical limit

## 📐 Mixed Unit Behavior

### Unit Equivalence
Some units are exactly equivalent:

```swift
// These produce the same result:
.inches(1.0)           // = 1440 twips
.centimeters(2.54)     // = 1440 twips (exact)

// These are approximately equivalent:
.inches(1.0)           // = 1440 twips
.millimeters(25.4)     // = 1439 twips (1 twip difference)
```

### ⚠️ Common Unit Confusion
**Important**: Points and inches are NOT equivalent!

```swift
// ❌ WRONG - These are very different:
.points(1440)          // = 28800 twips (72 inches!)
.inches(1.0)           // = 1440 twips (1 inch)

// ✅ CORRECT - These are equivalent:
.points(72.0)          // = 1440 twips (1 inch)
.inches(1.0)           // = 1440 twips (1 inch)
```

## 🚨 Potential Issues and Warnings

### 1. Unit Confusion
**Most Common Issue**: Confusing points with inches for page margins.

```swift
// ❌ This will create 72-inch margins!
pageMargins: UserFriendlyPageMargins(
    top: .points(1440),    // 72 inches!
    left: .points(1440)    // 72 inches!
)

// ✅ This creates 1-inch margins:
pageMargins: UserFriendlyPageMargins(
    top: .inches(1.0),     // 1 inch
    left: .inches(1.0)     // 1 inch
)
```

### 2. Truncation vs Rounding
Values are truncated, not rounded, which can be surprising:

```swift
// ❌ This might not work as expected:
Measurement.points(0.499).twips  // = 9, not 10
Measurement.points(0.999).twips  // = 19, not 20

// ✅ Use slightly larger values:
Measurement.points(0.5).twips    // = 10
Measurement.points(1.0).twips    // = 20
```

### 3. Very Small Values
Tiny values may become 0, making them ineffective:

```swift
// ❌ These will be 0:
Measurement.inches(0.0001).twips  // = 0
Measurement.points(0.01).twips    // = 0

// ✅ Use minimum effective values:
Measurement.inches(0.001).twips   // = 1
Measurement.points(0.1).twips     // = 2
```

### 4. Negative Values
Negative values are preserved but may cause unexpected behavior in Word processors:

```swift
// ⚠️ These work but may look strange:
pageMargins: UserFriendlyPageMargins(
    top: .inches(-1.0),    // Negative margin
    left: .inches(-0.5)    // Negative margin
)
```

## 📊 Performance Considerations

### Large Documents
- **Complex styling**: No performance impact (tested with 10x repeated content)
- **Large values**: No performance impact (tested up to 1,000,000 inches)
- **Mixed units**: No performance impact

### Memory Usage
- **Unit conversions**: Minimal memory overhead
- **Large configurations**: Linear memory usage with configuration complexity

## ✅ Best Practices

### 1. Use Appropriate Units
```swift
// ✅ Good practices:
pageMargins: UserFriendlyPageMargins(
    top: .inches(1.0),        // Page margins in inches
    left: .inches(0.75)       // Page margins in inches
),
defaultFont: UserFriendlyFontConfig(
    size: .points(12.0)       // Font sizes in points
),
spacing: UserFriendlySpacing(
    before: .points(6.0)      // Spacing in points
)
```

### 2. Avoid Unit Confusion
```swift
// ✅ Clear and explicit:
let config = UserFriendlyDocxStylingConfig(
    pageMargins: UserFriendlyPageMargins(
        top: .inches(1.0),        // 1 inch top margin
        right: .inches(0.75),     // 0.75 inch right margin
        bottom: .inches(1.0),     // 1 inch bottom margin
        left: .inches(0.75)       // 0.75 inch left margin
    )
)
```

### 3. Test Edge Cases
```swift
// ✅ Test your configuration:
let testConfig = UserFriendlyDocxStylingConfig(
    pageMargins: UserFriendlyPageMargins(
        top: .inches(0.1),        // Test small margins
        left: .inches(10.0)       // Test large margins
    )
)
let converter = MarkdownToDocxConverter(userFriendlyConfig: testConfig)
let docxData = try converter.convert(markdown: "Test document")
```

## 🔧 Troubleshooting

### Common Problems and Solutions

| Problem | Cause | Solution |
|---------|-------|----------|
| Margins too large | Used points instead of inches | Use `.inches()` for page margins |
| Font too small | Used inches instead of points | Use `.points()` for font sizes |
| Borders invisible | Width too small | Use at least `.points(0.5)` |
| Values not working | Too small (truncated to 0) | Use larger values |
| Unexpected results | Unit confusion | Double-check unit types |

### Debugging Tips
```swift
// Print conversion results:
let margin = Measurement.inches(1.0)
print("1 inch = \(margin.twips) twips")

let font = UserFriendlyFontConfig(size: .points(12.0))
print("12pt font = \(font.toFontConfig().size) half-points")
```

## 📋 Summary

### ✅ What Works Well
- All positive values (0.0 to ∞)
- All negative values
- Fractional values (with truncation)
- Mixed units in same configuration
- Large values
- Complex styling configurations

### ⚠️ What to Watch Out For
- Unit confusion (points vs inches)
- Very small values (may become 0)
- Truncation behavior (not rounding)
- Negative margins (may look strange)

### 🚨 What to Avoid
- Using points for page margins (use inches)
- Using inches for font sizes (use points)
- Values smaller than 0.001 inches or 0.01 points
- Expecting rounding behavior

The system is robust and handles most edge cases gracefully, but understanding the conversion behavior helps avoid common pitfalls. 