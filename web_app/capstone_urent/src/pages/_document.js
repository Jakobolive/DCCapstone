import { Html, Head, Main, NextScript } from "next/document";
import Footer from '../components/footer/footer';
import Header from '../components/header/header';

export default function Document() {
  return (
    <Html lang="en">
      <Head />
      <body>
        <Header />
        <Main />
        <NextScript />
        <Footer />
      </body>
    </Html>
  );
}
