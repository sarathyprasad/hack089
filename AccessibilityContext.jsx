import React, { createContext, useContext, useState, useEffect } from 'react';
import { useLanguage } from './LanguageContext';

const AccessibilityContext = createContext(null);

export function AccessibilityProvider({ children }) {
  const { lang } = useLanguage();
  
  // Font scale: 'normal' (1x), 'large' (1.15x), 'xlarge' (1.3x)
  const [fontSize, setFontSize] = useState(() => {
    return localStorage.getItem('gov_font_size') || 'normal';
  });

  // High contrast mode for outdoor/sunlight/low-vision readability
  const [highContrast, setHighContrast] = useState(() => {
    return localStorage.getItem('gov_high_contrast') === 'true';
  });

  // Speech narration state
  const [isSpeaking, setIsSpeaking] = useState(false);

  useEffect(() => {
    localStorage.setItem('gov_font_size', fontSize);
    const root = document.documentElement;
    if (fontSize === 'large') {
      root.style.setProperty('--font-scale', '1.12');
      root.classList.add('font-scale-large');
      root.classList.remove('font-scale-xlarge');
    } else if (fontSize === 'xlarge') {
      root.style.setProperty('--font-scale', '1.25');
      root.classList.add('font-scale-xlarge');
      root.classList.remove('font-scale-large');
    } else {
      root.style.setProperty('--font-scale', '1');
      root.classList.remove('font-scale-large', 'font-scale-xlarge');
    }
  }, [fontSize]);

  useEffect(() => {
    localStorage.setItem('gov_high_contrast', highContrast ? 'true' : 'false');
    if (highContrast) {
      document.documentElement.classList.add('high-contrast');
    } else {
      document.documentElement.classList.remove('high-contrast');
    }
  }, [highContrast]);

  // Voice narration helper using Web Speech API
  const speakText = (text, customLang = null) => {
    if (!('speechSynthesis' in window)) {
      alert('Voice assistant is not supported in this browser. Please use Chrome, Edge, or Firefox.');
      return;
    }

    if (isSpeaking) {
      window.speechSynthesis.cancel();
      setIsSpeaking(false);
      return;
    }

    window.speechSynthesis.cancel();

    const utterance = new SpeechSynthesisUtterance(text);
    const targetLang = customLang || lang;

    // Map language code to speech synthesis BCP-47 tag
    switch (targetLang) {
      case 'HI':
        utterance.lang = 'hi-IN';
        break;
      case 'OR':
        utterance.lang = 'or-IN';
        break;
      case 'BN':
        utterance.lang = 'bn-IN';
        break;
      case 'TE':
        utterance.lang = 'te-IN';
        break;
      default:
        utterance.lang = 'en-IN';
        break;
    }

    utterance.rate = 0.95;
    utterance.pitch = 1.0;

    utterance.onstart = () => setIsSpeaking(true);
    utterance.onend = () => setIsSpeaking(false);
    utterance.onerror = () => setIsSpeaking(false);

    window.speechSynthesis.speak(utterance);
  };

  const stopSpeaking = () => {
    if ('speechSynthesis' in window) {
      window.speechSynthesis.cancel();
      setIsSpeaking(false);
    }
  };

  const toggleHighContrast = () => {
    setHighContrast((prev) => !prev);
  };

  const cycleFontSize = () => {
    if (fontSize === 'normal') setFontSize('large');
    else if (fontSize === 'large') setFontSize('xlarge');
    else setFontSize('normal');
  };

  return (
    <AccessibilityContext.Provider
      value={{
        fontSize,
        setFontSize,
        cycleFontSize,
        highContrast,
        setHighContrast,
        toggleHighContrast,
        isSpeaking,
        speakText,
        stopSpeaking,
      }}
    >
      {children}
    </AccessibilityContext.Provider>
  );
}

export function useAccessibility() {
  const context = useContext(AccessibilityContext);
  if (!context) {
    throw new Error('useAccessibility must be used within an AccessibilityProvider');
  }
  return context;
}
