import { Link } from "react-router-dom";
import { FaExclamationTriangle } from "react-icons/fa";

const NotFound = () => {
  return (
    <section className="c-not-found">
      <FaExclamationTriangle className="c-not-found__icon" />
      <h1 className="">404 Not Found</h1>
      <p className="">This page does not exist</p>
      <Link to="/" className="c-btn c-btn-back">
        Back to Homepage
      </Link>
    </section>
  );
};

export default NotFound;
