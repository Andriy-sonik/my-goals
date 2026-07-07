export const useTheme = () => {
  const theme = useState<string>(
    'theme',
    () => 'light',
  );

  const setTheme = (newTheme: string) => {
    theme.value = newTheme;

    // document.documentElement.setAttribute(
    //   'data-theme',
    //   newTheme,
    // );
  };

  return {
    theme,
    setTheme,
  };
};