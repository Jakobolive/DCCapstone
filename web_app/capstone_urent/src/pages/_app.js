import Header from '../components/header/header';
import Footer from '../components/footer/footer';
import '../styles/globals.css'; // Make sure you include your global styles

function MyApp({ Component, pageProps }) {
  return (
    <>
      <Header />
      <Component {...pageProps} />
      <Footer />
    </>
  );
}

export default MyApp;